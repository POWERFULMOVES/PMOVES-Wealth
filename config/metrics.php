<?php

/*
 * metrics.php
 * PMOVES.AI Enhancement - Metrics configuration
 *
 * Configuration for Prometheus metrics endpoint.
 * Enable via ENABLE_METRICS environment variable.
 */

return [
    // Enable/disable metrics endpoint globally
    'enabled' => env('ENABLE_METRICS', false),

    // Include specific metric types
    'include' => [
        // Database connectivity check
        'database' => env('METRICS_INCLUDE_DB', true),

        // Memory usage metrics (current and peak)
        'memory' => env('METRICS_INCLUDE_MEMORY', true),

        // Application uptime in seconds
        'uptime' => env('METRICS_INCLUDE_UPTIME', true),
    ],
];
