FROM alpine:3.19.1

RUN apk add --no-cache sqlite

# DB_PATH required!
ENV DB_PATH=""
ENV DB_NAME=""
ENV REPLICA_PATH=""
ENV TEMP_PATH=/tmp
ENV CHECK_INTERVAL=10
ENV EXECUTION_INTERVAL=600

COPY --from=litestream/litestream:0.3.13 /usr/local/bin/litestream /usr/local/bin/litestream
COPY restore.sh /restore.sh
RUN chmod +x restore.sh
ENTRYPOINT ["/restore.sh"]
CMD []