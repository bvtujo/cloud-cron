FROM alpine:latest

RUN apk add curl jq bash

COPY scripts .

CMD ["/bin/bash"]
ENTRYPOINT ["./beeminder.sh"]

