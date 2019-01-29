FROM alpine:3.8

COPY bye /usr/bin/bye
RUN chmod +x /usr/bin/bye

ENTRYPOINT ["/bin/sh"]
CMD ["-c", "/usr/bin/bye"]
