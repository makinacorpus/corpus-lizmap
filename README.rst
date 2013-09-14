saltstates makina tree
===========================

Prerequisite
----------------
Install those packages::

    apt-get install -y build-essential m4 libtool pkg-config autoconf gettext bzip2 groff man-db automake libsigc++-2.0-dev tcl8.5
    apt-get install git python-dev swig libssl-dev libzmq-dev


Install mastersalt
----------------------
Be sure that the FQDN for the top master salt machine is 'mastersalt.makina-corpus.net' before runninig the base hightstate call

Create the salt top & develop code::

    mkdir /srv/
    git clone git@gitorious.makina-corpus.net:makinacorpus/salt-admin-pillar.git /srv/pillar
    git clone git@gitorious.makina-corpus.net:makinacorpus/salt-admin.git /srv/salt

Run the install buildout::

    cd /srv/salt
    python bootstrap.py
    bin/buildout

Install the base salt states infastructure::

    /srv/salt/makina-states/bin/salt-call state.highstate --local -ldebug

Accept both on local and master salt daemons the minion key::

    mastersalt-key -A
    salt-key -A


Install a new salt-managed box
-------------------------------
See the makina-states repository's Readme instruction

