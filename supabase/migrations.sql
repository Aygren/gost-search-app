-- ==========================================
-- Скрипт инициализации базы данных (Supabase)
-- Проект: GOST Search App (Векторный поиск по ГОСТ)
-- ==========================================

-- 1. ВКЛЮЧЕНИЕ РАСШИРЕНИЯ ДЛЯ ВЕКТОРОВ
-- Активируем расширение pgvector для работы с эмбеддингами
CREATE EXTENSION IF NOT EXISTS vector;

-- 2. ТАБЛИЦА: Документы ГОСТ (Чанки и Эмбеддинги)
CREATE TABLE IF NOT EXISTS public.gost_documents (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    gost_code varchar(100),               -- Номер ГОСТа (напр., "ГОСТ Р 57144-2016")
    title text NOT NULL,                  -- Название стандарта/главы
    content text NOT NULL,                -- Текст конкретного чанка
    
    -- Колонка для хранения векторов (размерность 1536 подходит для OpenAI / text-embedding-3-small)
    embedding vector(1536),               
    
    created_at timestamptz DEFAULT now()
);

-- 3. ИНДЕКС: HNSW для сверхбыстрого поиска сходства векторов
-- Используем cosine distance (косинусное расстояние), так как это стандарт для OpenAI
CREATE INDEX IF NOT EXISTS gost_documents_embedding_hnsw_idx 
ON public.gost_documents USING hnsw (embedding vector_cosine_ops);

-- 4. БЕЗОПАСНОСТЬ: Включение RLS и создание политики чтения
ALTER TABLE public.gost_documents ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'gost_documents' AND policyname = 'Allow public read access'
    ) THEN
        CREATE POLICY "Allow public read access" 
        ON public.gost_documents FOR SELECT 
        USING (true);
    END IF;
END
$$;

-- 5. ФУНКЦИЯ (RPC): Векторный поиск сходства документов
-- Вызывается из приложения через supabase.rpc('match_gost_documents', ...)
CREATE OR REPLACE FUNCTION public.match_gost_documents (
  query_embedding vector(1536),
  match_threshold float,
  match_count int
)
RETURNS TABLE (
  id uuid,
  gost_code varchar(100),
  title text,
  content text,
  similarity float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    id,
    gost_code,
    title,
    content,
    1 - (gost_documents.embedding <=> query_embedding) AS similarity
  FROM public.gost_documents
  WHERE 1 - (gost_documents.embedding <=> query_embedding) > match_threshold
  ORDER BY gost_documents.embedding <=> query_embedding
  LIMIT match_count;
$$;