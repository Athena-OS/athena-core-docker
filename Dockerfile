FROM athenaos/base:latest

ENV PUSER=athena
ENV PUID=1000

RUN pacman -Syu --noconfirm

#######################################################
###                  BASIC PACKAGES                 ###
#######################################################

RUN pacman -Syu --noconfirm --needed accountsservice dialog gcc inetutils make man-db man-pages most nano nbd net-tools netctl pv rsync sudo timelineproject-hg vi

#######################################################
###                   DEPENDENCIES                  ###
#######################################################

RUN pacman -Syu --noconfirm --needed exa pocl

#######################################################
###                      FONTS                      ###
#######################################################

RUN pacman -Syu --noconfirm --needed adobe-source-han-sans-cn-fonts adobe-source-han-sans-jp-fonts adobe-source-han-sans-kr-fonts gnu-free-fonts noto-fonts-emoji ttf-jetbrains-mono ttf-jetbrains-mono-nerd

#######################################################
###                    UTILITIES                    ###
#######################################################

RUN pacman -Syu --noconfirm --needed asciinema bash-completion bashtop bat bc blesh-git cmatrix cowsay cron downgrade espeakup figlet file-roller fortune-mod git gnome-keyring imagemagick jdk-openjdk jq lib32-glibc lolcat lsd myman nano-syntax-highlighting ncdu neofetch nyancat openbsd-netcat openvpn orca p7zip paru pfetch polkit powershell-bin python-pywhat reflector sl superbfetch-git textart tidy tk tmux toilet-fonts tree ufw unzip vim vnstat wget which xclip xcp xmlstarlet zoxide
RUN pacman -Syu --noconfirm --needed openssl shellinabox

#######################################################
###                ATHENA REPOSITORY                ###
#######################################################

RUN pacman -Syu --noconfirm --needed athena-neofetch-config athena-nvim-config athena-powershell-config athena-system-config athena-tmux-config athena-vim-config athena-zsh cyber-toolkit figlet-fonts htb-toolkit nist-feed

RUN sed -i "/PACMAN=/d" /usr/local/bin/athena-motd
RUN sed -i "/echo -e \"\$B    PACMAN/d" /usr/local/bin/athena-motd
RUN echo "athena-motd" >> /etc/zsh/zprofile
RUN sed -i "s/source ~\/.bash_aliases/source ~\/.bash_aliases\nsource ~\/.bashrc no-repeat-flag/g" /etc/skel/.zshrc
RUN sed -i "s/  neofetch/#  neofetch/g" /etc/skel/.zshrc

RUN systemd-machine-id-setup
RUN rm -rf /etc/skel/.bashrc.pacnew /etc/skel/.flag-work-once

RUN useradd -ms /bin/zsh $PUSER
RUN usermod -aG lp,rfkill,sys,wheel -u "$PUID" $PUSER && echo "$PUSER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$PUSER
RUN chmod 044 /etc/sudoers.d/$PUSER
RUN echo -e "$PUSER\n$PUSER" | passwd "$PUSER"

USER $PUSER:$PUSER
WORKDIR /home/$PUSER

# Running as login shell for executing /etc/zsh/zprofile script and the custom MOTD
CMD ["/bin/zsh", "-l"]
