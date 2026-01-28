<?php

/*
 * MetricsController.php
 * PMOVES.AI Enhancement - Prometheus metrics endpoint
 *
 * This file is part of PMOVES-Wealth (Firefly III fork).
 * Adds Prometheus-compatible /metrics endpoint for observability.
 *
 * Metrics are enabled via ENABLE_METRICS environment variable.
 */
declare(strict_types=1);

namespace FireflyIII\Http\Controllers\System;

use FireflyIII\Http\Controllers\Controller;
use FireflyIII\User;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;

/**
 * Class MetricsController.
 *
 * Provides Prometheus-compatible metrics endpoint for PMOVES.AI observability.
 * No external dependencies required - uses existing Laravel infrastructure.
 */
class MetricsController extends Controller
{
    private bool $enabled;
    private array $config;

    public function __construct()
    {
        $this->enabled = config('metrics.enabled', env('ENABLE_METRICS', false));
        $this->config = [
            'include_db' => config('metrics.include.database', env('METRICS_INCLUDE_DB', true)),
            'include_memory' => config('metrics.include.memory', env('METRICS_INCLUDE_MEMORY', true)),
            'include_uptime' => config('metrics.include.uptime', env('METRICS_INCLUDE_UPTIME', true)),
        ];
    }

    /**
     * Returns Prometheus-compatible metrics in text format.
     *
     * Metrics included:
     * - app_up: Service availability (1 if healthy)
     * - app_db_up: Database connectivity (1 if connected)
     * - app_memory_usage_bytes: Current memory usage
     * - app_memory_peak_bytes: Peak memory usage
     * - app_uptime_seconds: Application uptime (if available)
     *
     * @return Response Prometheus text format metrics
     */
    public function index(): Response
    {
        // Return 404 if metrics not enabled
        if (!$this->enabled) {
            return response('Metrics disabled', 404);
        }

        $metrics = [];

        // Service health
        $metrics[] = '# HELP app_up Service availability (1 = healthy)';
        $metrics[] = '# TYPE app_up gauge';
        $metrics[] = 'app_up 1';

        // Database connectivity
        if ($this->config['include_db']) {
            $dbStatus = $this->checkDatabase();
            $metrics[] = '# HELP app_db_up Database connectivity (1 = connected)';
            $metrics[] = '# TYPE app_db_up gauge';
            $metrics[] = 'app_db_up ' . $dbStatus;
        }

        // Memory metrics
        if ($this->config['include_memory']) {
            $memory = memory_get_usage(true);
            $peak = memory_get_peak_usage(true);
            $metrics[] = '# HELP app_memory_usage_bytes Current memory usage in bytes';
            $metrics[] = '# TYPE app_memory_usage_bytes gauge';
            $metrics[] = 'app_memory_usage_bytes ' . $memory;
            $metrics[] = '# HELP app_memory_peak_bytes Peak memory usage in bytes';
            $metrics[] = '# TYPE app_memory_peak_bytes gauge';
            $metrics[] = 'app_memory_peak_bytes ' . $peak;
        }

        // Uptime (if available)
        if ($this->config['include_uptime'] && defined('LARAVEL_START')) {
            $uptime = microtime(true) - LARAVEL_START;
            $metrics[] = '# HELP app_uptime_seconds Application uptime in seconds';
            $metrics[] = '# TYPE app_uptime_seconds gauge';
            $metrics[] = 'app_uptime_seconds ' . round($uptime, 2);
        }

        return response(implode("\n", $metrics), 200, [
            'Content-Type' => 'text/plain; version=0.0.4',
        ]);
    }

    /**
     * Check database connectivity.
     *
     * @return int 1 if connected, 0 if failed
     */
    private function checkDatabase(): int
    {
        try {
            DB::connection()->getPdo();
            return 1;
        } catch (\Exception $e) {
            return 0;
        }
    }
}
