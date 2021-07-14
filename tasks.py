from invoke import task, run, Exit
from os import environ as env
import os.path
from pathlib import Path
import configparser

# read settings
HOME = run("git rev-parse --show-toplevel").stdout.strip()
config = configparser.ConfigParser()
config.read("%s/config.ini" % HOME)
PROJECT = config["TF"]["PROJECT"]
BUCKET = config["TF"]["BUCKET"]
REGION = config["TF"]["REGION"]
AWS_PROFILE = config["TF"]["AWS_PROFILE"]


def check_env():
    """
    Doing all necessary checks
    """

    if AWS_PROFILE not in env:
        print("Please specify the %s environment variable" % AWS_PROFILE)
        return
    if "PWD" not in env:
        print("PWD environment variable is not set")
        return


def list_dirs(path):
    """
    Get list of terraform dirs
    """

    dirs = []
    for file_path in Path(path).glob("**/*.tf"):
        if ".terraform" not in str(file_path):
            dirname = os.path.dirname(file_path)
            if dirname not in dirs:
                dirs.append(dirname)
    return dirs


@task
def init(c):
    """
    Init s3 backend
    """

    check_env()
    pwd = env["PWD"]
    print("Running terraform init in the", pwd)
    c.run("rm -rf .terraform")
    output = (
        'terraform init \
                -backend-config "bucket=%s" \
                -backend-config "region=%s" \
                -backend-config "key=%s%s/terraform.tfstate" \
                '
        % (BUCKET, REGION, PROJECT, pwd.split(HOME)[1])
    )
    output += '-backend-config "profile=%s"' % env[AWS_PROFILE]
    c.run(output, echo=True)


@task
def lint(c):
    """
    Run the linter
    """

    if "CI" in env:
        list_path = HOME
    else:
        list_path = env["PWD"]
    for dir_path in list_dirs(list_path):
        print("Running terraform linter in the", dir_path)
        if not os.path.isfile("%s/README.md" % dir_path):
            raise Exit("Each Terraform env should have README.md!!!")
        if "CI" in env:
            c.run(
                "cd %s && terraform fmt -check=true || (echo 'Run terraform fmt before commit!!!'; exit 1)"
                % dir_path
            )
        else:
            c.run("cd %s && terraform fmt" % dir_path, echo=True)


@task
def validate(c):
    """
    Run the validate
    """

    if "CI" in env:
        list_path = HOME
    else:
        list_path = env["PWD"]
    for dir_path in list_dirs(list_path):
        print("Running terraform validate in the", dir_path)
        c.run(
            "cd %s \
                && terraform init -input=false -backend=false \
                && terraform validate \
                && tflint "
            % dir_path,
            echo=True,
        )
