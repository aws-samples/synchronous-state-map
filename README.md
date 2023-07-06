# Custom-App-One
A Custom serverless Application

### Console SSM Automation Role
A role must be added to each AWS account SSM Automation Documents are going to be ran manually via the AWS console.  

### Unit Testing
To Run Unit Tests:
* Install dependencies: `pip install -r tests/requirements.txt`
* Execute: `pytest`

Test Config:
* path of files to test is located in [pytest.ini](./pytest.ini) config file
* use the `testpaths` section to specify pattern of files to run (filenames ending with `_test.py` in the `tests` directory, or its subdirectories, is recommended)
* use the `pythonpath` section to specify python code root
* the name of tests must start with `test_` 

[pytest Docs](https://docs.pytest.org/en/7.1.x/contents.html)


