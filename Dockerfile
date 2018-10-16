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

ENV GLOBAL_GEMS_PATH /root/gems
ENV LOCAL_GEMS_PATH /app/.data/gems
ENV NODE_BINS_PATH /root/node_bins

RUN mkdir -p $GLOBAL_GEMS_PATH
RUN mkdir -p $LOCAL_GEMS_PATH

ENV GEM_HOME $LOCAL_GEMS_PATH
ENV GEM_PATH $LOCAL_GEMS_PATH:$GLOBAL_GEMS_PATH
ENV PATH $GLOBAL_GEMS_PATH/bin:$LOCAL_GEMS_PATH/bin:$NODE_BINS_PATH:$PATH

COPY install_ruby /usr/local/bin/
COPY install_node /usr/local/bin/

########### install project dependencies (SAMPLE) ###########

# RUN install_ruby 2.4.2
# RUN install_node 8.12.0 yarn

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
