# -*- coding: utf-8 -*-
"""
Created on Sun Oct 25 11:33:12 2015

This script unwraps archives an commits the files to a pre-configured github repo

PJD 25 Oct 2015     - Started file
PJD 28 Oct 2015     - Finalised file and recreated github repo
                    TODO:

@author: pauldurack
"""

import glob,os,pdb,shutil
from string import replace
from subprocess import call

homeDir = '/Users/pauldurack/Downloads/Sources/'

#%% Get file list
files = glob.glob(os.path.join(homeDir,'nap*'))
files.sort()

versions = []
for a,b in enumerate(files):
    vers = replace(b.split('/')[-1],'.tgz','')
    vers = replace(vers,'.tar.gz','')
    vers = replace(vers,'nap','')
    vers = replace(vers,'src','')
    versions += [vers]

#%% Create directory tree, clone and setup git info
os.chdir('/sync/git/')
shutil.rmtree('Tcl-NAP')
# The following requires a configured repo on github
cmd = 'git clone https://github.com/durack1/Tcl-NAP.git'
fnull = open(os.devnull,'w')
p = call(cmd,stdout=fnull,shell=True)
os.chdir('Tcl-NAP')
# Configure local git info
cmd = 'git config --global user.email "me@pauldurack.com"'
p = call(cmd,stdout=fnull,shell=True)
cmd = 'git config --global user.name "Paul J. Durack"'
p = call(cmd,stdout=fnull,shell=True)
fnull.close()

#%% Unwrap archives, commit and tag
napDir = False
for a,b in enumerate(files):
    print 'Processing: ',b
    if versions[a] == '4.1.0':
        napDir = True
    # Open fnull to write to
    fnull = open(os.devnull,'w')
    # Purge existing generic subdirs
    cmd = 'rm -rf data generic html installer library tests tex unix'
    p = call(cmd,stdout=fnull,shell=True)
    # Untar
    if napDir:
        cmd = ''.join(['tar -xvzf ',b])
        p = call(cmd,stdout=fnull,shell=True)
        os.chdir('nap')
        napDirs = os.listdir('.')
        if '.DS_Store' in napDirs:
            napDirs.remove('.DS_Store')
        for c,d in enumerate(napDirs):
            shutil.move(d,'/sync/git/Tcl-NAP/')
        #pdb.set_trace()
        os.chdir('/sync/git/Tcl-NAP/')
        shutil.rmtree('nap')
    else:
        cmd = ''.join(['tar -xvzf ',b])
        p = call(cmd,stdout=fnull,shell=True)
    # Purge tar files
    cmd = 'rm -f */*.tar.gz */*.tgz'
    p = call(cmd,stdout=fnull,shell=True)
    # Git add, commit, push, tag and push
    cmd = 'git add *'
    p = call(cmd,stdout=fnull,shell=True)
    versionCommitNote = ''.join([versions[a],' commit'])
    cmd = ''.join(['git commit -am "v',versionCommitNote,'"'])
    print cmd
    p = call(cmd,stdout=fnull,shell=True)
    cmd = 'git push'
    print cmd
    p = call(cmd,stdout=fnull,shell=True)
    cmd = ''.join(['git tag -a "v',versions[a],'" -m "v',versionCommitNote,'"'])
    p = call(cmd,stdout=fnull,shell=True)
    cmd = 'git push --tags'
    p = call(cmd,stdout=fnull,shell=True)
    # Cleanup
    fnull.close()
    del(cmd,fnull,p)
