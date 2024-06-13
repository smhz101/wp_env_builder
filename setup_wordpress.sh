#!/bin/bash

# Script Name: Instant WordPress Environment Setup
# Description: This script creates a new WordPress environment for a custom plugin.
# Args: PROJECT_NAME
# Author: Muzammil Hussain
# Date Created: 01-08-2023

# Load configuration
CONFIG_FILE=.env

# Function to check command existence
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "Error: $1 command not found. Please install $2."
        exit 1
    fi
}

# Function to set up Docker
setup_docker() {
    cat > docker-compose.yml <<- EOM
version: '3.3'
services:
   db:
     image: mysql:5.7
     volumes:
       - db_data:/var/lib/mysql
     restart: always
     environment:
       MYSQL_ROOT_PASSWORD: somewordpress
       MYSQL_DATABASE: wordpress
       MYSQL_USER: wordpress
       MYSQL_PASSWORD: wordpress
   wordpress:
     depends_on:
       - db
     image: wordpress:latest
     ports:
       - "8000:80"
     restart: always
     environment:
       WORDPRESS_DB_HOST: db:3306
       WORDPRESS_DB_USER: wordpress
       WORDPRESS_DB_PASSWORD: wordpress
       WORDPRESS_DB_NAME: wordpress
volumes:
    db_data: {}
EOM

    docker-compose up -d

    sleep 20

    docker exec -it $(docker ps -qf "name=${PROJECT_NAME}_wordpress_1") bash -c "wp core install --url=localhost:8000 --title='$PROJECT_NAME' --admin_user=$ADMIN_USERNAME --admin_password=$ADMIN_PASSWORD --admin_email='$AUTHOR_EMAIL' --path=/var/www/html"

    docker exec -it $(docker ps -qf "name=${PROJECT_NAME}_wordpress_1") bash -c "echo \"define( 'WP_DEBUG', true );
    define( 'WP_DEBUG_LOG', true );
    define( 'WP_DEBUG_DISPLAY', true );
    @ini_set( 'display_errors', 1 );\" >> /var/www/html/wp-config.php"
    echo "Debugging and error reporting enabled."
}

# Function to remove project
remove_project() {
    echo "Removing project $PROJECT_NAME..."
    valet unlink $PROJECT_NAME
    rm -rf $DIR/$PROJECT_NAME
    mysql -h 127.0.0.1 -u $DB_USER -p$DB_PASS -e "DROP DATABASE $PROJECT_NAME;"
    echo "Project $PROJECT_NAME removed successfully."
    exit 0
}

# Load config values
if [ -f $CONFIG_FILE ]; then
    source $CONFIG_FILE
else
    echo "Configuration file .env not found. Please create one from .env.example."
    exit 1
fi

# Variables
PROJECT_NAME=$1

# Check if required commands are available
check_command wp "WP-CLI"
check_command mysql "MySQL"
check_command valet "Valet"

# Interactive mode if no project name provided
if [ -z "$PROJECT_NAME" ]; then
    echo "Please provide the following information:"
    read -p "Enter project name: " PROJECT_NAME
    read -p "Enter description: " DESCRIPTION
fi

# Replace spaces with hyphens, and convert to lowercase
PROJECT_NAME=$(echo $PROJECT_NAME | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr '_' '-' )

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        --dir=*)
        DIR="${arg#*=}"
        shift
        ;;
        --remove)
        REMOVE=true
        shift
        ;;
        --description=*)
        DESCRIPTION="${arg#*=}"
        shift
        ;;
        --plugins=*)
        PLUGINS="${arg#*=}"
        shift
        ;;
    esac
done

# If remove argument was provided, remove the project
[ "$REMOVE" = true ] && remove_project

# Create project directory
mkdir -p $DIR/$PROJECT_NAME
cd $DIR/$PROJECT_NAME

# Check if database exists
DB_EXISTS=$(mysqlshow --user=$DB_USER --password=$DB_PASS $PROJECT_NAME | grep -v Wildcard | grep -o $PROJECT_NAME)

[ "$DB_EXISTS" == "$PROJECT_NAME" ] && PROJECT_NAME="${PROJECT_NAME}_$(date +%s)"

# Create MySQL database
mysql -h 127.0.0.1 -u $DB_USER -p$DB_PASS -e "CREATE DATABASE $PROJECT_NAME;"

# Setup WordPress
wp core download
while [ ! -f wp-config-sample.php ]; do sleep 1; done
wp config create --dbname=$PROJECT_NAME --dbuser=$DB_USER --dbpass=$DB_PASS
wp core install --url=$PROJECT_NAME.test --title="$PROJECT_NAME" --admin_user=$ADMIN_USERNAME --admin_password=$ADMIN_PASSWORD --admin_email="$AUTHOR_EMAIL"

# Install plugins
IFS=',' read -ra PLUGIN_ARRAY <<< "$PLUGINS"
for PLUGIN in "${PLUGIN_ARRAY[@]}"; do
    PLUGIN_EXISTS=$(wp plugin get $PLUGIN --field=name 2>/dev/null)
    [ -z "$PLUGIN_EXISTS" ] && wp plugin install $PLUGIN --activate
done

# Create project plugin
mkdir wp-content/plugins/$PROJECT_NAME
wp scaffold plugin $PROJECT_NAME --plugin_name="$PROJECT_NAME" --plugin_description="$DESCRIPTION" --plugin_author="$AUTHOR_NAME" --plugin_author_uri="$AUTHOR_WEBSITE" --plugin_uri="$PLUGIN_URI/$PROJECT_NAME" --activate

# Enable debugging
if [ -f wp-config.php ]; then
    WP_DEBUG_DEFINED=$(wp eval "echo defined( 'WP_DEBUG' ) && WP_DEBUG;")
    [ "$WP_DEBUG_DEFINED" != "1" ] && echo "define( 'WP_DEBUG', true );" >> wp-config.php
    WP_DEBUG_LOG_DEFINED=$(wp eval "echo defined( 'WP_DEBUG_LOG' ) && WP_DEBUG_LOG;")
    [ "$WP_DEBUG_LOG_DEFINED" != "1" ] && echo "define( 'WP_DEBUG_LOG', true );" >> wp-config.php
    WP_DEBUG_DISPLAY_DEFINED=$(wp eval "echo defined( 'WP_DEBUG_DISPLAY' ) && WP_DEBUG_DISPLAY;")
    [ "$WP_DEBUG_DISPLAY_DEFINED" != "1" ] && echo "define( 'WP_DEBUG_DISPLAY', true );" >> wp-config.php
    echo "@ini_set( 'display_errors', 1 );" >> wp-config.php
fi

# Link Valet
valet link $PROJECT_NAME
echo "Site linked successfully. Access your new WordPress site at http://$PROJECT_NAME.test"

# Open site in default browser
[[ "$OSTYPE" == "linux-gnu"* ]] && xdg-open "http://$PROJECT_NAME.test/wp-admin"
[[ "$OSTYPE" == "darwin"* ]] && open "http://$PROJECT_NAME.test/wp-admin"