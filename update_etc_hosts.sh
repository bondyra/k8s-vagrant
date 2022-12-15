config_file="config.json"
assets_dir=$(jq -r '.assets_dir' $config_file)

cat $assets_dir/_APPEND_THIS_TO_ETC_HOSTS >> /etc/hosts
