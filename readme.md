# Instant WordPress Environment Setup

This project provides a script to quickly set up a new WordPress environment for a custom plugin. It supports both Valet and Docker environments.

## Features

- Sets up a new WordPress installation
- Configures WordPress with a custom plugin
- Supports Valet and Docker environments
- Installs specified plugins
- Enables debugging and error reporting

## Requirements

- [WP-CLI](https://wp-cli.org/)
- [MySQL](https://www.mysql.com/)
- [Valet](https://laravel.com/docs/8.x/valet) or [Docker](https://www.docker.com/)

## Usage

### 1. Clone the Repository

```bash
git clone https://github.com/smhz101/wp_env_builder.git
cd wp_env_builder
```

### 2. Create a `.env` File

Copy the `.env.example` file to `.env` and edit it with your configuration details.

```bash
cp .env.example .env
```

### 3. Edit the `.env` File

Open the `.env` file in your favorite text editor and configure the following variables:

```bash
# MySQL Credentials
DB_USER=your_mysql_user
DB_PASS=your_mysql_password

# Author Information
AUTHOR_NAME="Your Name"
AUTHOR_EMAIL="your_email@example.com"
AUTHOR_WEBSITE="https://yourwebsite.com"
PLUGIN_URI="https://yourpluginuri.com"

# Plugins to Install (comma-separated)
PLUGINS="woocommerce,query-monitor,performance-lab,health-check,elementor,wp-reset,user-switching,log-deprecated-notices,rewrite-rules-inspector,wp-crontrol"

# Environment (valet or docker)
ENVIRONMENT="valet"
```

### 4. Run the Script

Run the `setup_wordpress.sh` script with your project name as an argument. You can also provide additional arguments for directory, description, and plugins.

```bash
./setup_wordpress.sh project_name
```

**Example**
```bash
./setup_wordpress.sh my_project --dir=~/Sites --description="My Custom Plugin" --plugins="woocommerce,elementor"
```

## Script Arguments

-   `PROJECT_NAME`: The name of your project.
-   `--dir=DIR`: Specify the directory to create the project in. Default is `~/Sites`.
-   `--remove`: Remove the project.
-   `--description=DESCRIPTION`: Specify the plugin description. Default is "A custom plugin".
-   `--plugins=PLUGINS`: Specify the plugins to install (comma-separated).

## Removing a Project

To remove a project, use the `--remove` argument:

```bash
./setup_wordpress.sh project_name --remove
```

## Accessing Your WordPress Site

-   Once the script has finished, your new WordPress site will be accessible at `http://project_name.test`.
-   The admin panel can be accessed at `http://project_name.test/wp-admin`.
-   Use the admin username and password specified in the `.env` file (`ADMIN_USERNAME` and `ADMIN_PASSWORD`).

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contributing

Contributions are welcome! Please fork the repository and use a feature branch. Pull requests are warmly welcome.

## Troubleshooting

If you encounter any issues, please check the following:

-   Ensure all required commands (`wp`, `mysql`, `valet`, `docker`) are installed and accessible from your terminal.
-   Verify the `.env` file is properly configured with correct MySQL credentials and other necessary details.
-   Check for any error messages during script execution and address them accordingly.

If you still face issues, feel free to open an issue on the [GitHub repository](https://github.com/smhz101/wp_env_builder/issues).

## Author

[Muzammil Hussain](https://github.com/smhz101)


This `README.md` file provides a comprehensive guide to using your Instant WordPress Environment Setup project, including setup instructions, usage examples, and troubleshooting tips. It should help users get started with your script quickly and efficiently.
