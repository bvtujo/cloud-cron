FROM alpine:latest

RUN apk add curl jq bash

COPY scripts/beeminder.sh .

CMD ["/bin/bash"]
ENTRYPOINT ["./beeminder.sh"]

