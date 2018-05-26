# Rails with Jenkinsfile and Dockerfile

This is a skeletal rails application with a Jenkinsfile demonstrating
the inclusion of MySQL as a Docker container to facilitate running
tests against a live database.

## How it works:

The first run of the pipeline fires up an instance of MySQL and builds the
application's Dockerfile while MySQL is booting.

Jenkins will then wait for the database to be ready before running the
test suite and reporting the results.

Subsequent runs will check if the database is running and run the tests
immediately after the container is built.

MySQL is left running because currently it takes several minutes to boot.
