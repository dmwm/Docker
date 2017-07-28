#! /usr/bin/env python

from __future__ import print_function

import glob
import json
import os
import time
import traceback
from collections import defaultdict

import jinja2
import xunitparser
from github import Github

pylintReportFile = 'pylint.jinja'
pylintSummaryFile = 'pylintSummary.jinja'
unitTestSummaryFile = 'unitTestReport.jinja'
pyfutureSummaryFile = 'pyfutureSummary.jinja'
pycodestyleReportFile = 'pycodestyle.jinja'

okWarnings = ['0511', '0703', '0613']

summaryMessage = ''
longMessage = ''
reportOn = {}
failed = False


def buildPylintReport(templateEnv):
    with open('LatestPylint/pylintReport.json', 'r') as reportFile:
        report = json.load(reportFile)

        pylintReportTemplate = templateEnv.get_template(pylintReportFile)
        pylintSummaryTemplate = templateEnv.get_template(pylintSummaryFile)

        # Process the template to produce our final text.
        pylintReport = pylintReportTemplate.render({'report': report, 'okWarnings': okWarnings})
        pylintSummaryHTML = pylintSummaryTemplate.render({'report': report, 'filenames': sorted(report.keys())})

    # Figure out if pylint failed

    failed = False
    failures = 0
    warnings = 0
    comments = 0

    for filename in report.keys():
        if 'test' in report[filename]:
            for event in report[filename]['test']['events']:
                if event[1] in ['W', 'E'] and event[2] not in okWarnings:
                    failed = True
                    failures += 1
                elif event[1] in ['W', 'E']:
                    warnings += 1
                else:
                    comments += 1
            if report[filename]['test'].get('score', None):
                if float(report[filename]['test']['score']) < 9 and (float(report[filename]['test']['score']) <
                                                                     float(report[filename]['base'].get('score', 0))):
                    failed = True
                elif float(report[filename]['test']['score']) < 8:
                    failed = True

    pylintSummary = {'failures': failures, 'warnings': warnings, 'comments': comments}

    return failed, pylintSummaryHTML, pylintReport, pylintSummary

def buildPyCodeStyleReport(templateEnv):
    """
    Build the report for pycodestyle (also known as pep8)
    """

    errors = defaultdict(list)
    pycodestyleReportHTML = None
    pycodestyleSummary = {'comments': 0}

    try:
        with open('LatestPylint/pep8.txt', 'r') as reportFile:
            pycodestyleReportTemplate = templateEnv.get_template(pycodestyleReportFile)
            for line in reportFile:
                pycodestyleSummary['comments'] += 1
                fileName, line, error = line.split(':', 2)
                error = error.lstrip().lstrip('[')
                errorCode, message = error.split('] ', 1)
                errors[fileName].append((line, errorCode, message))
        pycodestyleReportHTML = pycodestyleReportTemplate.render({'report': errors})
    except:
        print("Was not able to open or parse pycodestyle tests")
        traceback.print_exc()

    return False, pycodestyleReportHTML, pycodestyleSummary

def buildTestReport(templateEnv):
    unstableTests = []
    testResults = {}

    try:
        with open('UnstableTests.txt') as unstableFile:
            for line in unstableFile:
                unstableTests.append(line.strip())
    except:
        print("Was not able to open list of unstable tests")

    for kind, directory in [('base', './MasterUnitTests/'), ('test', './LatestUnitTests/')]:
        print("Scanning directory %s" % directory)
        for xunitFile in glob.iglob(directory + '*/nosetests-*.xml'):
            print("Opening file %s" % xunitFile)
            with open(xunitFile) as xf:
                ts, tr = xunitparser.parse(xf)
                for tc in ts:
                    testName = '%s:%s' % (tc.classname, tc.methodname)
                    if testName in testResults:
                        testResults[testName].update({kind: tc.result})
                    else:
                        testResults[testName] = {kind: tc.result}

    failed = False
    errorConditions = ['error', 'failure']

    newFailures = []
    unstableChanges = []
    okChanges = []
    added = []
    deleted = []

    for testName, testResult in sorted(testResults.items()):
        oldStatus = testResult.get('base', None)
        newStatus = testResult.get('test', None)
        if oldStatus and newStatus and testName in unstableTests:
            if oldStatus != newStatus:
                unstableChanges.append({'name': testName, 'new': newStatus, 'old': oldStatus})
        elif oldStatus and newStatus:
            if oldStatus != newStatus:
                if newStatus in errorConditions:
                    failed = True
                    newFailures.append({'name': testName, 'new': newStatus, 'old': oldStatus})
                else:
                    okChanges.append({'name': testName, 'new': newStatus, 'old': oldStatus})
        elif newStatus:
            added.append({'name': testName, 'new': newStatus, 'old': oldStatus})
            if newStatus in errorConditions:
                failed = True
        elif oldStatus:
            deleted.append({'name': testName, 'new': newStatus, 'old': oldStatus})

    changed = newFailures or added or deleted or unstableChanges or okChanges
    stableChanged = newFailures or added or deleted or okChanges

    unitTestSummaryTemplate = templateEnv.get_template(unitTestSummaryFile)
    unitTestSummaryHTML = unitTestSummaryTemplate.render({'newFailures': newFailures,
                                                          'added': added,
                                                          'deleted': deleted,
                                                          'unstableChanges': unstableChanges,
                                                          'okChanges': okChanges,
                                                          'errorConditions': errorConditions,
                                                          })

    unitTestSummary = {'newFailures': len(newFailures), 'added': len(added), 'deleted': len(deleted),
                       'okChanges': len(okChanges), 'unstableChanges': len(unstableChanges)}
    print("Unit Test summary %s" % unitTestSummary)
    return failed, unitTestSummaryHTML, unitTestSummary


def buildPyFutureReport(templateEnv):
    pyfutureSummary = {}
    failed = False

    try:
        with open('LatestFuturize/added.message', 'r') as messageFile:
            lines = messageFile.readlines()
            if len(lines):
                lt = [l.strip() for l in lines]
                lt1 = [l for l in lt if l]
                lt2 = [l.replace("*", "") for l in lt1]
                pyfutureSummary['added.message'] = lt2
                failed = True
    except:
        print("Was not able to open file added.message")

    try:
        with open('LatestFuturize/test.patch', 'r') as patchFile:
            lines = patchFile.readlines()
            if len(lines):
                pyfutureSummary['test.patch'] = lines
                failed = True
    except:
        print("Was not able to open file test.patch")

    try:
        with open('LatestFuturize/idioms.patch', 'r') as patchFile:
            lines = patchFile.readlines()
            if len(lines):
                pyfutureSummary['idioms.patch'] = lines
    except:
        print("Was not able to open file idioms.patch")

    pyfutureSummaryTemplate = templateEnv.get_template(pyfutureSummaryFile)
    pyfutureSummaryHTML = pyfutureSummaryTemplate.render(
        {'report': pyfutureSummary, 'filenames': sorted(pyfutureSummary.keys())})

    return failed, pyfutureSummary, pyfutureSummaryHTML


templateLoader = jinja2.FileSystemLoader(searchpath="templates/")
templateEnv = jinja2.Environment(loader=templateLoader, trim_blocks=True, lstrip_blocks=True)

with open('artifacts/PullRequestReport.html', 'w') as html:
    failedPylint, pylintSummaryHTML, pylintReport, pylintSummary = buildPylintReport(templateEnv)
    try:
        failedUnitTests, unitTestSummaryHTML, unitTestSummary = buildTestReport(templateEnv)
    except IOError:
        failedUnitTests, unitTestSummaryHTML, unitTestSummary = 0, '', ''
    failedPyFuture, pyfutureSummary, pyfutureSummaryHTML = buildPyFutureReport(templateEnv)
    failedPycodestyle, pycodestyleReport, pycodestyleSummary = buildPyCodeStyleReport(templateEnv)

    html.write(unitTestSummaryHTML)
    html.write(pylintSummaryHTML)
    html.write(pylintReport)
    if pycodestyleReport:
        html.write(pycodestyleReport)
    html.write(pyfutureSummaryHTML)

gh = Github(os.environ['DMWMBOT_TOKEN'])
codeRepo = os.environ.get('CODE_REPO', 'WMCore')
teamName = os.environ.get('WMCORE_REPO', 'dmwm')
repoName = '%s/%s' % (teamName, codeRepo)

issueID = None

if 'ghprbPullId' in os.environ:
    issueID = os.environ['ghprbPullId']
    mode = 'PR'
elif 'TargetIssueID' in os.environ:
    issueID = os.environ['TargetIssueID']
    mode = 'Daily'

repo = gh.get_repo(repoName)
issue = repo.get_issue(int(issueID))
reportURL = os.environ['BUILD_URL'].replace('jenkins/job',
                                            'jenkins/view/All/job') + 'artifact/artifacts/PullRequestReport.html'

statusMap = {False: {'ghStatus': 'success', 'readStatus': 'succeeded'},
             True: {'ghStatus': 'failure', 'readStatus': 'failed'}, }

message = 'Jenkins results:\n'

if unitTestSummary:  # Some repos have no unit tests
    message += ' * Unit tests: %s\n' % statusMap[failedUnitTests]['readStatus']
    if unitTestSummary['newFailures']:
        message += '   * %s new failures\n' % unitTestSummary['newFailures']
    if unitTestSummary['deleted']:
        message += '   * %s tests deleted\n' % unitTestSummary['deleted']
    if unitTestSummary['okChanges']:
        message += '   * %s tests no longer failing\n' % unitTestSummary['okChanges']
    if unitTestSummary['added']:
        message += '   * %s tests added\n' % unitTestSummary['added']
    if unitTestSummary['unstableChanges']:
        message += '   * %s changes in unstable tests\n' % unitTestSummary['unstableChanges']

message += ' * Pylint check: %s\n' % statusMap[failedPylint]['readStatus']
if pylintSummary['failures']:
    message += '   * %s warnings and errors that must be fixed\n' % pylintSummary['failures']
if pylintSummary['warnings']:
    message += '   * %s warnings\n' % pylintSummary['warnings']
if pylintSummary['comments']:
    message += '   * %s comments to review\n' % pylintSummary['comments']

message += ' * Pycodestyle check: %s\n' % statusMap[failedPycodestyle]['readStatus']
if pycodestyleSummary['comments']:
    message += '   * %s comments to review\n' % pycodestyleSummary['comments']

message += ' * Python3 compatibility checks: %s\n' % statusMap[failedPyFuture]['readStatus']
if failedPyFuture:
    message += '   * fails python3 compatibility test\n '
if 'idioms.patch' in pyfutureSummary and pyfutureSummary['idioms.patch']:
    message += '   * there are suggested fixes for newer python3 idioms\n '

message += "\nDetails at %s\n" % reportURL
status = issue.create_comment(message)

lastCommit = repo.get_pull(int(issueID)).get_commits().get_page(0)[-1]
lastCommit.create_status(state=statusMap[failedPylint]['ghStatus'], target_url=reportURL + '#pylint',
                         description='Finished at ' + time.strftime("%d %b %Y %H:%M GMT"), context='Pylint')
lastCommit.create_status(state=statusMap[failedUnitTests]['ghStatus'], target_url=reportURL + '#unittests',
                         description='Finished at ' + time.strftime("%d %b %Y %H:%M GMT"), context='Unit tests')
lastCommit.create_status(state=statusMap[failedPyFuture]['ghStatus'], target_url=reportURL + '#pyfuture',
                         description='Finished at ' + time.strftime("%d %b %Y %H:%M GMT"),
                         context='Python3 compatibility')

if failedPylint:
    print('Testing of python code. DMWM-FAIL-PYLINT')
else:
    print('Testing of python code. DMWM-SUCCEED-PYLINT')

if failedUnitTests:
    print('Testing of python code. DMWM-FAIL-UNIT')
else:
    print('Testing of python code. DMWM-SUCCEED-UNIT')

if failedPyFuture:
    print('Testing of python code. DMWM-FAIL-PY27')
else:
    print('Testing of python code. DMWM-SUCCEED-PY27')
