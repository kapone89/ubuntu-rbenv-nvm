FROM buildpack-deps:bionic-scm

SHELL ["/bin/bash", "-c"]

ENV TZ=Europe/Warsaw
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install basic dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  bzip2 \
  ca-certificates \
  git \
  gnupg \
  curl \
  autoconf \
  bison \
  build-essential \
  libyaml-dev \
  libreadline6-dev \
  zlib1g-dev \
  libncurses5-dev \
  libffi-dev \
  libgdbm5 \
  libgdbm-dev\
  wget \
  vim \
  imagemagick \
  tzdata \
  libmysqlclient-dev \
  libsqlite3-dev \
  libpq-dev \
  postgresql-client \
  libmemcached-dev \
  apt-utils \
  libssl1.0-dev \
  && rm -rf /var/lib/apt/lists/*

# some tweaks
RUN echo fs.inotify.max_user_watches=524288 | tee /etc/sysctl.d/40-max-user-watches.conf
RUN echo "require 'irb/ext/save-history'; IRB.conf[:SAVE_HISTORY] = 200; IRB.conf[:HISTORY_FILE] = '/root/.irb-history'" >> /root/.irbrc

# installl rbenv
ENV RBENV_ROOT /root/.rbenv
ENV CONFIGURE_OPTS "--disable-install-doc"
ENV PATH $RBENV_ROOT/shims:$RBENV_ROOT/bin:$PATH
RUN git clone https://github.com/rbenv/rbenv.git ${RBENV_ROOT}
RUN git clone https://github.com/rbenv/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build
RUN git clone https://github.com/jf/rbenv-gemset.git ${RBENV_ROOT}/plugins/rbenv-gemset
RUN echo 'eval "$(rbenv init -)"' >> /root/.bashrc
RUN source ~/.bashrc

# install nvm
RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
ENV NVM_DIR /root/.nvm
RUN source /root/.bashrc

# create app dir
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

########### install project dependencies (SAMPLE) ###########

# ENV RUBY_VERSION "2.4.2"
# RUN rbenv install $RUBY_VERSION
# RUN rbenv global $RUBY_VERSION
# RUN gem install bundler
# RUN rbenv rehash
# ENV RBENV_GEMSETS "./.data/gems"
#
# ENV NODE_VERSION "8.12.0"
# RUN source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION
# ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
# RUN npm install -g yarn

############# build (SAMPLE) ##################

# COPY Gemfile .
# COPY Gemfile.lock .
# RUN bundle install --deployment --without="development test"
#
# COPY package.json .
# COPY yarn.lock .
# RUN yarn install
#
# COPY . .
# ENV RACK_ENV=production \
#     RAILS_ENV=production
#
# RUN bundle exec rake assets:precompile
#
# ENTRYPOINT bundle exec rails s -p 8080
