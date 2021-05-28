# TIE-50307 Real-time systems

--------------------------------------------------------------------------------
## Important Notice about LFS

This project uses a Git extension for versioning large binary files called [Git Large File Storage][git-lfs].

Every clone of this repository **MUST** initialize the Git LFS extension. Immediately after a clone operation, inside the repository, the following command **MUST** be issued:

~~~bash
git lfs install
~~~

The above command will setup the correct *hooks* in the <u>local copy</u> of the repository: these *hooks* will automate the use of the LFS extension, so that, transparently, using the usual workflow of `git add`/`git commit`/`git push`, a selection of the files will be stored differently.

The course VM already includes all the required dependencies to use this extension.

--------------------------------------------------------------------------------

## Quick guide to resume your work after rebooting the VM

If you are using HTTPS remotes, you might want to run `git config --global credential.helper 'cache --timeout=3600'` before cloning: this way you will have to input your username and password only after 1 hour without interacting with your remote.

1. `cd ~`
2. `git clone --recurse-submodules <STUDENT_REPO_URL> [<LOCAL_CLONE_DIR>]`
   - by default, if you don't specify `<LOCAL_CLONE_DIR>` the local clone will be in `~/NN/`, if for any reason, during the first exercise you used a different name or path, make sure to replicate the one you used previously, or the layers configuration you committed previously will be incorrect;
3. `cd <LOCAL_CLONE_DIR>; git lfs install && git lfs pull`


## Quick guide to pull new exercise instructions

It is sufficient to run the following script (**from the root of your repository**):

```bash
cd <STUDENT_REPO_ROOT>
scripts/update_from_course_upstream.sh
```

Alternatively you could [download the script from your browser][update_from_course_upstream] to `/tmp/`, and then run it **from the root of your repository**:

```bash
cd <STUDENT_REPO_ROOT>
bash /tmp/update_from_course_upstream.sh
```

## Quick guide to submit the exercise assignment

1. `git commit` - remember to *add* new files
2. `git push`
3. Create tag for submission in GitLab - format `ExNN_submissionN`
4. `git push --tags`
5. Submit a link to the tag on the corresponding assignment in [Moodle][moodle.COMP.CE.460]

## How to use SSH remotes

Using HTTPS remotes becomes quickly frustrating as it requires to input your credentials several times, even multiple times for a single `git` command.

Read [Using a persistent SSH key for project access][semipermanent-ssh-keys] snippet for tips on how to securely use a semipermanent `git` profile with SSH keys for the shared VM environment of the course.

**Note**: If you choose to setup access through SSH keys, remember to use the SSH remote URL to clone your student repository and for the `course_upstream` remote.

If you decide to use HTTPS remotes, you might want to run `git config --global credential.helper 'cache --timeout=3600'` before cloning: this way you will have to input your username and password only after 1 hour without interacting with your remote.

## Git Help

If you need training to use Git, visit [Git Course in Plussa][git-plussa].


[moodle.COMP.CE.460]: https://moodle.tuni.fi/course/view.php?id=9860
[git-plussa]: https://plus.tuni.fi/tie-git/v2/
[course_upstream project]: https://course-gitlab.tuni.fi/comp.ce.460-real-time-systems_2020-2021/course_upstream
[git-lfs]: https://git-lfs.github.com/
[semipermanent-ssh-keys]: https://course-gitlab.tuni.fi/comp.ce.460-real-time-systems_2020-2021/course_upstream/snippets/
[update_from_course_upstream]: https://course-gitlab.tuni.fi/comp.ce.460-real-time-systems_2020-2021/course_upstream/raw/master/scripts/update_from_course_upstream.sh
