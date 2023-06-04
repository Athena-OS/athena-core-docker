FROM athenaos/base:latest

ENV LANG=en_US.UTF-8
ENV TZ=Europe/Zurich
ENV PUSER=athena
ENV PUID=1000

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

RUN pacman -Syu --noconfirm --needed accountsservice dialog gcc inetutils make man-db man-pages most nano nbd net-tools netctl pv rsync sudo timelineproject-hg vi xdg-user-dirs

#######################################################
###                   DEPENDENCIES                  ###
#######################################################

RUN pacman -Syu --noconfirm --needed exa hwloc ocl-icd pocl

#######################################################
###                      FONTS                      ###
#######################################################

RUN pacman -Syu --noconfirm --needed adobe-source-han-sans-cn-fonts adobe-source-han-sans-jp-fonts adobe-source-han-sans-kr-fonts gnu-free-fonts ttf-jetbrains-mono ttf-jetbrains-mono-nerd

#######################################################
###                    UTILITIES                    ###
#######################################################

RUN pacman -Syu --noconfirm --needed asciinema bash-completion bashtop bat bc blesh-git cmatrix cowsay cron downgrade eog espeakup figlet file-roller fortune-mod git gnome-keyring imagemagick jdk-openjdk jq lib32-glibc lolcat lsd nano-syntax-highlighting ncdu neofetch nyancat openbsd-netcat openvpn orca p7zip paru pfetch polkit powershell-bin python-pywhat reflector sl textart tidy tk tmux toilet tree ufw unzip vim vnstat wget which xclip xcp xmlstarlet zoxide
RUN pacman -Syu --noconfirm --needed openssl shellinabox

#######################################################
###                ATHENA REPOSITORY                ###
#######################################################

RUN pacman -Syu --noconfirm --needed athena-neofetch-config athena-nvchad athena-powershell-config athena-system-config athena-tmux-config athena-vim-config athena-zsh figlet-fonts htb-tools myman nist-feed superbfetch-git toilet-fonts

RUN sed -i "/PACMAN=/d" /usr/local/bin/athena-motd
RUN sed -i "/echo -e \"\$B    PACMAN/d" /usr/local/bin/athena-motd
RUN echo "athena-motd" >> /etc/zsh/zprofile
RUN sed -i "s/source ~\/.bash_aliases/source ~\/.bash_aliases\nsource ~\/.bashrc/g" /etc/skel/.zshrc
RUN sed -iz "s/if \[\[ \\\$1 != no-repeat-flag \]\]; then\n  neofetch\nfi/#if \[\[ \\\$1 != no-repeat-flag \]\]; then\n#  neofetch\n#fi/g" /etc/skel/.zshrc

RUN systemd-machine-id-setup
RUN rm -rf /etc/skel/.bashrc.pacnew /etc/skel/.flag-work-once

RUN useradd -ms /bin/zsh $PUSER
RUN usermod -aG users,lp,network,power,sys,wheel -u "$PUID" $PUSER && echo "$PUSER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$PUSER
RUN chmod 044 /etc/sudoers.d/$PUSER
RUN echo -e "$PUSER\n$PUSER" | passwd "$PUSER"

USER $PUSER:$PUSER
WORKDIR /home/$PUSER
RUN xdg-user-dirs-update

# Running as login shell for executing /etc/zsh/zprofile script and the custom MOTD
CMD ["/bin/zsh", "-l"]
