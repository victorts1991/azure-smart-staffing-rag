# Estágio de Build
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Estágio Final
FROM python:3.11-slim
WORKDIR /app

# Copia dependências do estágio de build
COPY --from=builder /root/.local /root/.local
# Copia o código fonte (a pasta /app inteira)
COPY ./app ./app

# Garante que os binários do pip estejam no PATH
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

EXPOSE 8000

# Executa o uvicorn apontando para o pacote 'app.main'
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]