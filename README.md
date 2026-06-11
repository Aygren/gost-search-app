# 🚘 PDD AI Assistant: Multiplatform AI Legal Ecosystem

[Читать на русском языке](README.ru.md)

An intelligent AI legal assistant designed for express analysis of traffic accident circumstances and automated legal consulting based on the current Russian Traffic Regulations (PDD).

The project was developed as a course assignment for the Stepik platform and is a distributed production-ready ecosystem consisting of a Streamlit web interface and a Telegram bot with integrated Voice-to-Text (STT) support.

---

## 🔗 Live Project Links
* **Project Website:** [Streamlit Web App](https://pdd-ai-assistant-9rkbzk5lgw3ku5jusctmh3.streamlit.app/)
* **Telegram Bot:** [@AygrenPddBot](https://t.me/AygrenPddBot)

---

## 🔥 Key Feature & AI Architecture

Unlike basic RAG systems that perform simple keyword searching over documents, this project implements an advanced **Information Gathering Agent** pattern that emulates a real attorney qualification interview:

1. **Multi-stage JSON Analysis:** The primary analyst model examines the situation context and validates it against an official traffic police (GIBBD) checklist (direction of travel, priority signs, traffic light states).
2. **Road-logic Processing:** The AI identifies specific accident types (e.g., rear-end collisions, sideswipes) or traffic light behaviors at regulated intersections, dynamically adapting the interview script and reducing friction for a stressed driver.
3. **Context Retention & Questioning:** If the data gathered is insufficient to provide a legal verdict, the agent generates precise follow-up questions while maintaining session state.
4. **Hybrid Full-Text Search RAG:** Only after gathering 100% of the required facts (or after 2 full dialogue cycles) the query optimizer triggers to fetch relevant traffic regulations from the database for the final legal teardown.

---

## 🛠 Tech Stack

* **Development Language:** Python 3.12
* **Orchestration & AI Chains:** LangChain (context state management via `InMemoryChatMessageHistory`)
* **AI Models (System Brain):** Mistral AI (`mistral-small-latest`) fine-tuned for hybrid output (free text + strict JSON mode)
* **Speech Recognition (STT):** Groq API (`whisper-large-v3`) — sub-second audio byte transcription
* **Knowledge Base & Search Backend:** Supabase (PostgreSQL). Built-in advanced linguistic full-text search (`tsvector`/`tsquery`) with automated Russian morphology lexeme generation.
* **Interfaces:** Streamlit (Web frontend) and pyTelegramBotAPI (Telegram bot wrapper)

---

## 📂 Repository Structure

~~~text
pdd-ai-assistant/
├── assets/                  # UI graphic assets (SVG logos)
├── supabase/                # Database configuration
│   └── migrations.sql       # Schema deployment, GIN indexes, and RPC text search function
├── src/                     # Core application source code
│   ├── __init__.py
│   ├── ai_assistant.py      # Core AI logic: JSON analyzer, RAG chains, Whisper STT integration
│   ├── search_pdd.py        # Database lookup module utilizing Supabase FTS
│   ├── tg_bot.py            # Telegram bot interface (processes text, voice, and commands)
│   └── upload_to_supabase.py# Script for initial parsing and loading PDD rules into the cloud
├── app.py                   # Streamlit web application entry point
├── requirements.txt         # Project external dependencies list
└── README.md                # English documentation
~~~

---

## 🚀 Local Deployment Guide

Execute the following commands sequentially in your system terminal:

### 1. Cloning and Environment Setup
~~~bash
# Clone the repository
git clone https://github.com/Aygren/pdd-ai-assistant.git
cd pdd-ai-assistant

# Create and activate virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows use: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
~~~

### 2. Database Configuration (Supabase & Full-Text Search)
The project utilizes native PostgreSQL linguistic engines to power search over regulations.
1. Create a new database project inside your **Supabase** dashboard.
2. Open the built-in **SQL Editor** in the Supabase control panel.
3. Copy and run the code from the **[supabase/migrations.sql](supabase/migrations.sql)** file. This instantly sets up tables, GIN indexes, and the RPC morphology search functions.
4. Run the setup script to populate the database with initial PDD rule chunks:
~~~bash
python -m src.upload_to_supabase
~~~

### 3. Environment Variables Configuration
Create a `.env` file in the root directory of the project and specify your API credentials:
~~~ini
MISTRAL_API_KEY=your_mistral_api_key_here
GROQ_API_KEY=your_groq_api_key_for_whisper
SUPABASE_URL=your_supabase_project_url_here
SUPABASE_KEY=your_supabase_anon_public_key_here
TG_BOT_TOKEN=your_telegram_bot_token_from_botfather
~~~

### 4. Running Components Locally

* **Run the Streamlit Web Application:**
~~~bash
streamlit run app.py
~~~
* **Run the Telegram Bot Interface:**
~~~bash
python -m src.tg_bot
~~~

---

## ☁️ Production Cloud Deployment Architecture

The system is designed as a distributed service tied to a unified backend:

1. **Web Interface (Streamlit Cloud):** Deployed on Streamlit Cloud, synchronized with the `main` branch. Environment variables are securely isolated inside the platform's Advanced Settings.
2. **Telegram Bot (Render.com):** Deployed as a background Web Service on Render. Auto-deploy is disabled for explicit developer version control.
   * **Build Command:** `pip install -r requirements.txt`
   * **Start Command:** `python -m http.server $PORT > /dev/null & python -m src.tg_bot`
3. **Availability Optimization (Cron-Job.org):** To prevent the free Render container from falling asleep, an external scheduler pings the application's web port every 15 minutes.

---

## 🚀 Project Roadmap & Perspectives
Based on the current MVP runtime analysis, the following areas have been identified for future development:
* **"Call a Lawyer" Button:** Integrating human-handovers for complex gray-area road scenarios where LLMs hit logical boundary limitations (e.g., dynamic priority shifts).
* **Driving School Integration (B2B):** Adapting the assistant as an interactive AI tutor helping students prepare for official state driving theory examinations.
* **Additional API Integrations:** Connecting gateway channels to check traffic fines or calculate insurance (OSAGO) price estimates on the fly.