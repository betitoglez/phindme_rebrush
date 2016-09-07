<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class DevelopmentLog
 */
class DevelopmentLog extends Model
{
    protected $table = 'development_log';

    protected $primaryKey = 'idDevelopment_log';

	public $timestamps = false;

    protected $fillable = [
        'sitio',
        'dato',
        'valor',
        'Issue_number',
        'fecha'
    ];

    protected $guarded = [];

        
}