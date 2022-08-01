#!/usr/bin/env bash
/usr/local/bundle/bin/rails db:create
/usr/local/bundle/bin/rails db:migrate

/usr/local/bundle/bin/rails server -b 0.0.0.0
