FROM alpine:3.8

COPY hello /usr/bin/hello
RUN chmod +x /usr/bin/hello

ENTRYPOINT ["/bin/sh"]
CMD ["-c", "/usr/bin/hello"]
