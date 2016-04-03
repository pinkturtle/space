flightplan = require "flightplan"

flightplan.target "space", [{
    host: "pinkturtle.space"
    username: "core"
    agent: process.env.SSH_AUTH_SOCK
  }]

flightplan.remote ["reboot"], (remote) ->
  remote.sudo("reboot --force --reboot")

flightplan.remote ["inspect", "default"], (remote) ->
  remote.exec "id"
  remote.exec "df /"
  remote.exec "docker images"
  remote.exec "docker ps --all"
  remote.exec "docker info"
  remote.exec "systemctl status space"

flightplan.remote "start", (remote) ->
  remote.sudo "systemctl start space"
  remote.exec "systemctl status space"

flightplan.remote "stop", (remote) ->
  remote.sudo "systemctl stop space"
  remote.exec "systemctl status space", failsafe: true

flightplan.remote ["setup_public_folder", "setup", "advance"], (remote) ->
  if remote.exec("ls pinkturtle.space", failsafe:yes, silent:yes).code isnt 0
    remote.log "Establishing pinkturtle.space folder for publically accesible files"
    remote.exec "mkdir pinkturtle.space"
  else
    remote.log "pinkturtle.space folder for publically accesible files is established"

flightplan.remote ["build_image", "setup", "advance"], (remote) ->
  remote.log "Removing exiting image files"
  remote.exec "rm -rf pinkturtle.space.image"

flightplan.local ["build_image", "setup", "advance"], (local) ->
  imageFiles = [
    "Dockerfile"
    "nginx.conf"
    "SSL/pinkturtle.space.crt"
    "SSL/pinkturtle.space.secret.key"
    "SSL/pinkturtle.space.secret.dhparams"
  ]
  local.log "Transfering image files:", JSON.stringify(imageFiles)
  local.transfer imageFiles, "/home/core/pinkturtle.space.image"

flightplan.remote ["build_image", "setup", "advance"], (remote) ->
  remote.log "Building /home/core/pinkturtle.space.image"
  remote.exec "docker build --tag pinkturtle.space.image /home/core/pinkturtle.space.image"
  remote.exec "docker images"

flightplan.local ["setup_service", "setup", "advance"], (local) ->
  local.log "Transfering space.service unit file"
  local.transfer "space.service", "/home/core"

flightplan.remote ["setup_service", "setup", "advance"], (remote) ->
  remote.log "Linking space.service with systemd"
  remote.sudo "systemctl link /home/core/space.service"
  remote.sudo "systemctl enable /home/core/space.service"

flightplan.remote ["remove_expired_docker_containers", "clean"], (remote) ->
  expiredContainerList = remote.exec("docker ps --all | grep Exited", {failsafe:yes}).stdout
  if expiredContainerList
    containerIDs = (entry.split(" ")[0] for entry in expiredContainerList.trim().split("\n")).join(" ")
    remote.log "Removing containers:", containerIDs
    remote.exec "docker rm #{containerIDs}"
  else
    remote.log "No expired docker containers."
#
flightplan.remote ["remove_expired_docker_images", "clean"], (remote) ->
  expiredImageList = remote.exec("docker images | grep '^<none>' | awk '{print $3}'", failsafe:yes).stdout
  if expiredImageList
    expiredImageIDs = (id for id in expiredImageList.trim().split("\n")).join(" ")
    console.info expiredImageIDs
    remote.log "Removing containers:", expiredImageIDs
    remote.exec("docker rmi #{expiredImageIDs}")
  else
    remote.log "No expired docker images."

flightplan.remote ["restart", "advance"], (remote) ->
  remote.sudo("systemctl restart space")
  remote.exec("systemctl status space")
