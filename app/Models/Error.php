<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class Error
 */
class Error extends Model
{
    protected $table = 'error';

    protected $primaryKey = 'id_error';

	public $timestamps = false;

    protected $fillable = [
        'fail_date',
        'site',
        'tabla',
        'transaction',
        'description',
        'stackTrace',
        'details'
    ];

    protected $guarded = [];

        
}