FROM athenaos/base:latest

ENV PUSER=athena
ENV PUID=1000

RUN pacman -Syyu --noconfirm --needed \
accountsservice bind dialog fakeroot gcc inetutils make man-db man-pages most nano nbd net-tools netctl pv rsync sudo timelineproject-hg vi \
eza pocl \
noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono ttf-jetbrains-mono-nerd \
asciinema bash-completion bashtop bat bc blesh-git cmatrix cowsay cron downgrade espeakup fastfetch figlet-fonts file-roller fortune-mod git imagemagick jdk-openjdk jq lib32-glibc lolcat lsd myman nano-syntax-highlighting ncdu nvchad-git nyancat openbsd-netcat openvpn orca p7zip paru pfetch polkit powershell-bin python-pywhat reflector sl superbfetch-git textart tidy tk tmux toilet-fonts tree ufw unzip vim vnstat wget which xclip xmlstarlet zoxide \
openssl \
athena-bash athena-config athena-powershell-config athena-tmux-config athena-vim-config athena-zsh cyber-toolkit htb-toolkit nist-feed

RUN sed -i "/PACMAN=/d" /usr/local/bin/athena-motd
RUN sed -i "/echo -e \"\$B    PACMAN/d" /usr/local/bin/athena-motd
RUN echo "athena-motd" >> /etc/zsh/zprofile
RUN sed -i "s/  fastfetch/#  fastfetch/g" /etc/skel/.zshrc

RUN systemd-machine-id-setup
RUN rm -rf /etc/skel/.bashrc.pacnew

RUN useradd -ms /bin/zsh $PUSER
RUN usermod -aG lp,rfkill,sys,wheel -u "$PUID" $PUSER && echo "$PUSER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$PUSER
RUN chmod 044 /etc/sudoers.d/$PUSER
RUN echo -e "$PUSER\n$PUSER" | passwd "$PUSER"

USER $PUSER:$PUSER
WORKDIR /home/$PUSER

# Running as login shell for executing /etc/zsh/zprofile script and the custom MOTD
CMD ["/bin/zsh", "-l"]
