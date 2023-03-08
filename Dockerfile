FROM athenaos/base:latest

ENV LANG=en_US.UTF-8
ENV TZ=Europe/Zurich
ENV PUSER=athena
ENV PUID=1000
ENV MOTD=/etc/motd

# Configure the locale; enable only en_US.UTF-8 and the current locale.
RUN sed -i -e 's~^\([^#]\)~#\1~' '/etc/locale.gen' && \
  echo -e '\nen_US.UTF-8 UTF-8' >> '/etc/locale.gen' && \
  if [[ "${LANG}" != 'en_US.UTF-8' ]]; then \
  echo "${LANG}" >> '/etc/locale.gen'; \
  fi && \
  locale-gen && \
  echo -e "LANG=${LANG}\nLC_ADDRESS=${LANG}\nLC_IDENTIFICATION=${LANG}\nLC_MEASUREMENT=${LANG}\nLC_MONETARY=${LANG}\nLC_NAME=${LANG}\nLC_NUMERIC=${LANG}\nLC_PAPER=${LANG}\nLC_TELEPHONE=${LANG}\nLC_TIME=${LANG}" > '/etc/locale.conf'

# Configure the timezone.
RUN echo "${TZ}" > /etc/timezone && \
  ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime

RUN pacman -Syu --noconfirm

#######################################################
###                  BASIC PACKAGES                 ###
#######################################################

RUN pacman -Syu --noconfirm --needed accountsservice btrfs-progs dialog gcc inetutils make man-db man-pages most nano nbd net-tools netctl pv rsync sudo timelineproject-hg xdg-user-dirs

#######################################################
###                   DEPENDENCIES                  ###
#######################################################

RUN pacman -Syu --noconfirm --needed exa python-libtmux python-libtmux sassc hwloc ocl-icd pocl

#######################################################
###                      FONTS                      ###
#######################################################

RUN pacman -Syu --noconfirm --needed adobe-source-han-sans-cn-fonts adobe-source-han-sans-jp-fonts adobe-source-han-sans-kr-fonts gnu-free-fonts nerd-fonts-jetbrains-mono ttf-jetbrains-mono

#######################################################
###                    UTILITIES                    ###
#######################################################

RUN pacman -Syu --noconfirm --needed asciinema bashtop bat bc cmatrix cowsay cron downgrade dunst eog espeakup figlet file-roller fortune-mod git gnome-keyring imagemagick jdk-openjdk jq lolcat lsd neofetch nyancat openbsd-netcat openvpn orca p7zip paru pfetch polkit python-pywhat reflector sl textart tidy tk tmux toilet tree ufw unzip vim vnstat wget which xclip xcp xmlstarlet zoxide
RUN pacman -Syu --noconfirm --needed openssl shellinabox

#######################################################
###                ATHENA REPOSITORY                ###
#######################################################

RUN pacman -Syu --noconfirm --needed athena-application-config athena-nvchad athena-welcome athena-zsh figlet-fonts htb-tools myman nist-feed superbfetch-git toilet-fonts

RUN athena-motd -f $MOTD
RUN echo "cat $MOTD" >> /etc/zsh/zprofile
RUN systemd-machine-id-setup
RUN useradd -ms /bin/zsh $PUSER
RUN usermod -aG users,lp,network,power,sys,wheel -u "$PUID" $PUSER && echo "$PUSER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$PUSER
RUN chmod 044 /etc/sudoers.d/$PUSER
RUN echo -e "root\nroot" | passwd "root"
RUN echo -e "$PUSER\n$PUSER" | passwd "$PUSER"
RUN sed -i "s/source ~\/.bash_aliases/source ~\/.bash_aliases\nsource ~\/.bashrc/g" /home/$PUSER/.zshrc

USER $PUSER:$PUSER
WORKDIR /home/$PUSER
RUN xdg-user-dirs-update

CMD ["/bin/zsh"]
