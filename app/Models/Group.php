<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class Group
 */
class Group extends Model
{
    protected $table = 'group';

    protected $primaryKey = 'id_Group';

	public $timestamps = false;

    protected $fillable = [
        'name',
        'privacy',
        'name_privacy',
        'mail_privacy',
        'id_User'
    ];

    protected $guarded = [];

        
}