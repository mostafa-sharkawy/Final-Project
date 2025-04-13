<?php
WP_CLI::add_command('test', function($args) {
    WP_CLI::line("Running basic tests...");
    
    // Test database connection
    global $wpdb;
    $result = $wpdb->get_var("SELECT 1");
    WP_CLI::success("Database connection: " . ($result === '1' ? 'OK' : 'Failed'));
    
    // Test plugin activation
    if (is_plugin_active('akismet/akismet.php')) {
        WP_CLI::success("Plugin is active");
    } else {
        WP_CLI::error("Plugin is not active");
    }
    
    // Add more tests as needed
});