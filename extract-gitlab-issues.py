#!/usr/bin/env python3

import argparse
import os
import requests

private_token = os.environ.get("GITLAB_PRIVATE_TOKEN")

def get_issues(baseurl, project_id):

    issues = []
    page = 1
    url = f"https://{baseurl}/api/v4/projects/{project_id}/issues?private_token={private_token}&per_page=100"
    while True:
        response = requests.get(url + f"&page={page}")
        page_issues = response.json()
        if not page_issues:
            break
        issues += page_issues
        page += 1

    return issues

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--baseurl", required=True)
    parser.add_argument("--project", required=True)
    parser.add_argument("--label", required=False, default="all")
    args = parser.parse_args()

    issues = get_issues(args.baseurl, args.project)
    for issue in issues:
        if (args.label == "all" or args.label in issue["labels"]):
            print(f"{issue['iid']}; {issue['title']}; {issue['state']}; https://{args.baseurl}/{args.project}/issues/{issue['iid']};")
