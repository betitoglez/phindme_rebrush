<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class Info
 */
class Info extends Model
{
    protected $table = 'info';

    protected $primaryKey = 'id_Info';

	public $timestamps = false;

    protected $fillable = [
        'info',
        'type'
    ];

    protected $guarded = [];

        
}