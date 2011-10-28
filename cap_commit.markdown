Credit: [mislav](https://gist.github.com/mislav)
Cloned from: [gist](https://gist.github.com/1203851)

Added function: capistrano multistage support

This is a Thor task that wraps the Capistrano "cap deploy:upload" command.
It uses git that provides a list of files to be uploaded.

After uploading, the web application is restarted so that changes may take effect.

## Usage

    thor cap:commit

Deploys files from the last (HEAD) commit.

    thor cap:commit HEAD^

Deploys files from the previous commit.

    thor cap:commit A..B

Deploys files that have changed in a diff between commits A to B.

    thor cap:commit origin/production..

Deploys files that have changed since the last state of "origin/production" branch.

    thor cap:commit --working

Deploys files currently modified in your working copy (i.e. not yet commited).

    thor cap:commit --working=app/views

Deploy only currently modified files under "app/views/" directory.

    thor cap:commit --environment=production
    thor cap:commit --e production

Deploy with multistage support

	thor cap:commit --stage=staging

Overrides the Capistrano variable "branch" to the value of "environment" parameter.

    thor cap:commit --no-restart

Don't restart the web application after uploading files.

## Notes

If any of the files under "public/stylesheets/" or "public/javascripts" are
uploaded, this task also invokes the custom "deploy:clear_cached_assets" Capistrano
task. After the application is restarted, Rails re-generates the cached assets.

Files under "spec/" and "features/" directories are not deployed since they
don't affect the production environment.