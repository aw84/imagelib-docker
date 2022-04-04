FROM openjdk:11
RUN mkdir /app
ADD run_app.sh /app/run_app.sh
RUN chmod +x /app/run_app.sh
CMD [ "/bin/bash", "-c", "/app/run_app.sh" ]