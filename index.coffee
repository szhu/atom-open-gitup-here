getActiveFilePath = () ->
  document.querySelector('.tree-view .selected')?.getPath?() ||
    atom.workspace.getActivePaneItem()?.buffer?.file?.path

getRootDir = () ->
  dirs = atom.project.getDirectories()
  defaultPath = dirs[0]?.path
  return defaultPath if dirs.length < 2
  activeFilePath = getActiveFilePath()
  return defaultPath if not activeFilePath
  for dir in dirs
    return dir.path if activeFilePath.indexOf(dir.path + '/') is 0
  defaultPath

filterProcessEnv = () ->
  env = {}
  for key, value of process.env
    env[key] = value if key not in [
      # Filter out environment variables leaked by the Atom process:
      'NODE_PATH', 'NODE_ENV', 'GOOGLE_API_KEY', 'ATOM_HOME'
    ]
  env

open = (filepath) ->
  dirpath = getRootDir()
  return if not dirpath
  command = atom.config.get 'open-gitup-here.command'
  require('child_process').exec command, cwd: dirpath, env: filterProcessEnv()

switch require('os').platform()
  when 'darwin'
    defaultCommand = 'open -b co.gitup.mac "$PWD"'
  else
    throw new Error("Sorry, GitUp is only supported on macOS.")

module.exports =
  config:
    command:
      type: 'string'
      default: defaultCommand
  activate: ->
    atom.commands.add 'atom-workspace',
      'open-gitup-here:open-root': (event) ->
        event.stopImmediatePropagation()
        open()
