# ============================================================
# Dockerfile — MoneyPrinterTurbo (API FastAPI para o Hub)
#
# Diferente do Dockerfile upstream (que sobe a WebUI Streamlit na 8501),
# este sobe a API REST na 8080 — que é como o Hub da Tropa fala com ele.
#
# Otimizações vs upstream:
# - Mirrors oficiais Debian + PyPI (upstream usa Aliyun/Tsinghua = lento fora da China)
# - CMD roda main.py (uvicorn API) em vez de Streamlit
# ============================================================
FROM python:3.11-slim-bookworm

WORKDIR /MoneyPrinterTurbo

ENV PYTHONPATH="/MoneyPrinterTurbo"

# System deps: ffmpeg (video), imagemagick (legendas), git (clones de assets).
# Usa mirror oficial Debian (rápido na VPS Brasil).
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        imagemagick \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Fix ImageMagick security policy (mesmo patch do upstream: permite @-paths).
RUN sed -i '/<policy domain="path" rights="none" pattern="@\*"/d' /etc/ImageMagick-6/policy.xml

# Instala deps Python (PyPI oficial, mais rápido na VPS).
COPY requirements.txt ./
RUN pip install --no-cache-dir --retries 3 --timeout 120 -r requirements.txt

# Código da aplicação.
COPY . .

# Porta da API FastAPI (config.listen_port default = 8080).
EXPOSE 8080

# Sobe a API (uvicorn via main.py), nao a WebUI Streamlit.
CMD ["python", "main.py"]
