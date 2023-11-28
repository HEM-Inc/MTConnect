#!/bin/sh
### Latest Approved MTConnect Instute Agent Instance

# ---- MTConnect Agent Instance ----
FROM mtconnect/agent AS mtc_agent

USER agent
COPY --chown=agent:agent ./styles/ /mtconnect/data/styles

VOLUME ["/mtconnect/config", "/mtconnect/log", "/mtconnect/data"]
ENTRYPOINT ["/usr/bin/mtcagent run /etc/mtconnect/data/agent.cfg"]

### EOF
