## **Current status**, what works so far:

### **Building & Testing:**
- Trivial one-step scripts, scripts/build.sh & scripts/runtests.sh (minimal, using CMake).
- Requires only a C++ compiler to be present (cross-platform with docker = easy).
- _No dependancies on anything else_ = Docker, GoCD or whatever is optional/easily replaceable.

        
### **Docker:**
- Two, again trivial, scripts (docker/build.sh & docker/runtests.sh) doing nothing more than starting a container, passing the above build/runtests scripts as argument.
- Dependencies like CMake & C++ compiler is managed in the docker image = very flexible.
- build.sh & runtests.sh (docker/..) pass artifacts using private registry, currently pointing to "localhost:5000" (which is easily configurable if hosting registry remotely).
- "Artifacts" are the whole build for that commit (source + compiled result).
        
### **GoCD:**
- Server & agents running in docker containers.
- Agents using "docker in docker" (through socket-binding, not pure "dind").
- All logic for the building & testing is in the repo, so starting new server instances is trivial. 
- Basic, ready to go scripts to fire up server & registry, automatically connecting agents to the server. (this should be replaced by docker-compose, but currently there is some host-setup needed which isn't trivial with docker-compose).      
- Pipeline configuration is kept in repository (server is thus minimal, basically contains nothing more than a "load remote config"-config).
- Jobs are minimal, not caring about artifacts etc. (this is managed by the docker build-scripts). Jobs just run "build.sh" & "runtests.sh", keeping the "heavy" logic out of the server.
        
        
## **TODO:**
- Fix docker-compose for GoCD setup, including registry.
- ~~Add test-result output (tests passed/failed, details of failes etc), perferably in HTML-friendly format.~~
- Add support for test coverage, result perferably in HTML-friendly format.
- Add support for static analysis, result perferably in HTML-friendly format.
- Do above as separate "pipeline steps", to that they can be move around in the pipeline config easily depending on their importance/time consumption etc.
