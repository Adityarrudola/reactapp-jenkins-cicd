Debugging Learnings from My Jenkins + DinD Setup
	
1. After switching to Docker-in-Docker, builds still failed because Jenkins couldn’t communicate with the Docker daemon. The root cause was networking — Jenkins and DinD were not on the same Docker network. Fixing this highlighted how critical container networking is in CI architectures.

2. One tricky failure was a “Bad substitution” error in the pipeline. This turned out to be due to using Bash-style syntax in a shell that didn’t support it. That’s when I learned Jenkins sh steps default to /bin/sh, not Bash — a subtle but important detail.

3. During deployment, I hit an error: --name expected one argument. After debugging, I found that an environment variable (ACI_NAME) was not being passed correctly. This showed how fragile CI/CD pipelines can be without proper environment validation.

4. Redeployment kept failing because Azure does not allow creating a container with an existing name. This led me to introduce a dedicated “Delete Old Container” stage, making the deployment idempotent and closer to production-grade behavior.

5. Over time, disk usage increased significantly due to unused Docker images. Adding a cleanup stage with docker system prune -af helped manage resources, highlighting the importance of maintaining CI infrastructure, not just pipelines.