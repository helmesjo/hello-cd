Starting with a first approach of the "Docker Builder Pattern", basically:

   BUILD:
    1. Create a Dockerfile.build that contains all tools necessary to build the source.
        - Copy/Mount (latter preferable) repo and set as working directory.
    2. Build the build-container and run.
       - Mount source and workingdir to make it build directly back to the "artifact folder".
   TEST:
    3. Create a Dockerfile that contains the minimum necessities to run the app/lib/executable.
    4. Build the runner-container and mount the artifact and set as working directory.
    5. Test against the built artifact (UI Tests, Acceptance tests, Performance tests...), by running the 
       runner-container and passing the test-runner as argument (to make it execute in the containers working-dir.

Something like this to get a good base for the pipeline-structure.

Next step will be to automate the GoCD server & agent startup sequence, and seperate out all pipeline configs into the repo (want to be able to create & remove the pipeline on a any server anywhere, anytime. So don't keep any configfiles stored on the actual server!







PROGRESS:

Getting things together, and fixed alot of issues with docker-in-docker (through docker.socket), user privileges etc.
TODO: Fix core.autocrlf/.gitattributes so that the whole repo is specificly LF (fixes all annoying issues with windows line endings).
Current issue is that the server (which runs on my pc, windows) changes lineendings for all files, so shell scripts fail to run etc.