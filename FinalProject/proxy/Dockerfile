FROM python:3.8

WORKDIR /usr/app/src

ENV VIRTUAL_ENV=/.venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install dependencies:
COPY ./requirements.txt .
RUN pip install --no-cache-dir --upgrade -r /usr/app/src/requirements.txt

# Run the script:
COPY ./app /usr/app/src

ENTRYPOINT ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]