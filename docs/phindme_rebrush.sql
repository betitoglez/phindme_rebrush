-- phpMyAdmin SQL Dump
-- version 4.0.10deb1
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 08-09-2016 a las 17:22:32
-- Versión del servidor: 5.6.19-0ubuntu0.14.04.1
-- Versión de PHP: 5.5.9-1ubuntu4.19

SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de datos: `phindme_rebrush`
--

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `BuildPrivacy`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `BuildPrivacy`(priv_ INT(8),name_priv_ INT(8),mail_priv_ INT(8),tabla VARCHAR(16),filtro VARCHAR(32),INOUT query1 VARCHAR(255))
BEGIN

  

  SET @q=CONCAT('SELECT privacy,name_privacy,mail_privacy INTO @_priv,@_name_priv,@_mail_priv FROM ',tabla,' WHERE ',filtro,' LIMIT 1');

  call SET_VALUES(@q);

  

  IF @_priv != priv_ THEN

    SET query1=CONCAT(query1,'privacy=',priv_,',');

  END IF;

  IF @_name_priv != name_priv_ THEN

    SET query1=CONCAT(query1,'name_privacy=',name_priv_,',');

  END IF;

  IF @_mail_priv != mail_priv_ THEN

    SET query1=CONCAT(query1,'mail_privacy=',mail_priv_,',');

  END IF;

END$$

DROP PROCEDURE IF EXISTS `BuildQuery`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `BuildQuery`(campo VARCHAR(32),valor VARCHAR(64),tabla VARCHAR(32),filtro VARCHAR(32),

										INOUT query1 VARCHAR(255),INOUT query2 VARCHAR(255),INOUT query3 VARCHAR(255))
BEGIN

  call SET_VALUES(CONCAT('SELECT ',campo,' INTO @field FROM ',tabla,' WHERE ',filtro,' LIMIT 1;'));

  IF @field IS NOT NULL THEN

    IF @field != valor THEN

	  SET @exists_data=0;

      IF tabla='contacts' THEN

	    SET @q = CONCAT('SELECT id_Contact INTO @exists_data FROM ',tabla,'_his',' WHERE ',filtro,' AND ',campo,'=''',@field,''' LIMIT 1;');

      ELSE

	    SET @q = CONCAT('SELECT id_',tabla,' INTO @exists_data FROM ',tabla,'_his',' WHERE ',filtro,' AND ',campo,'=''',@field,''' LIMIT 1;');

      END IF;

	  call SET_VALUES(@q);

      IF @exists_data IS NULL OR @exists_data=0 THEN

	    SET query1=CONCAT(query1,',',campo);

	    SET query2=CONCAT(query2,',''',@field,'''');

	  END IF;

	  SET query3=CONCAT(query3,campo,'=''',valor,''',');

	END IF;

  ELSE

    IF valor IS NOT NULL AND valor != '' THEN

	  SET query3=CONCAT(query3,campo,'=''',valor,''',');

	END IF; 

  END IF;

#call trazar('BuildQuery','query3: ',query3,50);

END$$

DROP PROCEDURE IF EXISTS `clear_log`$$
CREATE DEFINER=`admin`@`localhost` PROCEDURE `clear_log`()
DELETE FROM Development_log WHERE idDevelopment_log>1$$

DROP PROCEDURE IF EXISTS `contacts_Accept_friendrequest`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `contacts_Accept_friendrequest`(user_ INT,contact_ INT)
BEGIN

  INSERT INTO contacts(`id_User`,`id_Contact`) VALUES (user_,contact_);

  INSERT INTO contacts(`id_User`,`id_Contact`) VALUES (contact_,user_);

  DELETE FROM friendrequest WHERE id_User=contact_ AND id_Contact=user_;

END$$

DROP PROCEDURE IF EXISTS `contacts_Search`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `contacts_Search`(idUser_ INT,text_ VARCHAR(32))
BEGIN

  SET @SQL_=CONCAT('SELECT id_User,user,`name`,mail FROM vw_contacts WHERE contact=',idUser_,

  ' AND (user LIKE ''%',text_,'%'' collate ',GetLanguage(),

  ' OR `name` LIKE ''%',text_,'%'' collate ',GetLanguage(),

  ' OR SUBSTRING_INDEX(mail,''@'',1) LIKE ''%',text_,'%'')');

  call SET_VALUES(@SQL_);

END$$

DROP PROCEDURE IF EXISTS `DELETE_CONTACT`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `DELETE_CONTACT`(IN id_User_ INT(32),IN id_Contact_ INT(32))
BEGIN

  DECLARE info_id INT(32);

  DECLARE counter INT(8) DEFAULT 0;

  DECLARE infos CURSOR FOR SELECT id_Info FROM contactsinfo WHERE id_User=id_User_ AND id_Contact=id_Contact_;

  

  SELECT COUNT(id_Info) INTO counter FROM contactsinfo WHERE id_User=id_User_ AND id_Contact=id_Contact_ LIMIT 1;

  DELETE FROM contacts_his WHERE id_User=id_User_ AND id_Contact=id_Contact_;#many

  DELETE FROM info_his WHERE id_User=id_User_ AND id_Contact=id_Contact_;#many

  OPEN infos;

  info_table: LOOP

    IF counter = 0 THEN

      LEAVE info_table;

    ELSE

      FETCH infos INTO info_id;

      DELETE FROM contactsinfo WHERE id_User=id_User_ AND id_Contact=id_Contact_ AND id_Info=info_id;

      DELETE FROM info WHERE id_Info=info_id;

      SET counter:=counter-1;

    END IF;

  END LOOP info_table;

  DELETE FROM contacts WHERE id_User=id_User_ AND id_Contact=id_Contact_;#one

#call trazar('DELETE_CONTACT','deleted contacts:id_User',id_User_,70);

END$$

DROP PROCEDURE IF EXISTS `DELETE_GROUP_CONTACT`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `DELETE_GROUP_CONTACT`(idContact_ INT, idGroup_ INT)
BEGIN

  DELETE FROM contactsgroup WHERE id_Contact=idContact_ AND id_Group=idGroup_;

END$$

DROP PROCEDURE IF EXISTS `DELETE_GROUP_USER`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `DELETE_GROUP_USER`(id_ INT)
BEGIN

  DELETE FROM contactsgroup WHERE id_Group=id_;

  DELETE FROM `group` WHERE id_Group=id_;

END$$

DROP PROCEDURE IF EXISTS `DELETE_INFO_CONTACT`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `DELETE_INFO_CONTACT`(id_ INT)
BEGIN

  DECLARE tabla INT DEFAULT 0;

  DECLARE _info VARCHAR(64);

  DECLARE idUser_ INT(32) DEFAULT NULL;

  DECLARE idContact_ INT(32) DEFAULT NULL;

  SELECT id_User,id_Contact INTO idUser_,idContact_ FROM contactsinfo WHERE id_Info=id_;

  DELETE FROM contactsinfo WHERE id_Info=id_;

  SELECT info INTO _info FROM info WHERE id_Info=id_;

  INSERT INTO info_his VALUES(idUser_,idContact_,_info);

  DELETE FROM info WHERE id_Info=id_;

END$$

DROP PROCEDURE IF EXISTS `DELETE_INFO_USER`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `DELETE_INFO_USER`(id_ INT)
BEGIN

  DECLARE tabla INT DEFAULT 0;

  DECLARE _info VARCHAR(64);

  DECLARE idUser_ INT(32) DEFAULT NULL;

  SELECT id_User INTO idUser_ FROM userinfo WHERE id_Info=id_;

  DELETE FROM userinfo WHERE id_Info=id_;

  SELECT info INTO _info FROM info WHERE id_Info=id_;

  INSERT INTO info_his VALUES(idUser_,null,_info);

  DELETE FROM info WHERE id_Info=id_;

END$$

DROP PROCEDURE IF EXISTS `DELETE_USER`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `DELETE_USER`(IN `id_` INT(32))
    MODIFIES SQL DATA
BEGIN

  UPDATE register SET Active=0 WHERE id_User=id_;

END$$

DROP PROCEDURE IF EXISTS `DROP_USER`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `DROP_USER`(IN `id_` INT(32))
    MODIFIES SQL DATA
BEGIN

  DECLARE info_id INT(32);

  DECLARE counter INT(8) DEFAULT 0;

  DECLARE infos CURSOR FOR SELECT id_Info FROM userinfo WHERE id_User=id_User_;

  DECLARE infosCon CURSOR FOR SELECT id_Info FROM contactsinfo WHERE id_User=id_User_;

  

  SELECT COUNT(id_Info) INTO counter FROM userinfo WHERE id_User=id_User_ LIMIT 1;

  OPEN infos;

  info_table: LOOP

    IF counter = 0 THEN

      LEAVE info_table;

    ELSE

      FETCH infos INTO info_id;

      DELETE FROM userinfo WHERE id_User=id_User_ AND id_Info=info_id;

      DELETE FROM info WHERE id_Info=info_id;

      SET counter:=counter-1;

    END IF;

  END LOOP info_table;

  

  SELECT COUNT(id_Info) INTO counter FROM contactsinfo WHERE id_User=id_User_ LIMIT 1;

  OPEN infosCon;

  info_tableCon: LOOP

    IF counter = 0 THEN

      LEAVE info_tableCon;

    ELSE

      FETCH infosCon INTO info_id;

      DELETE FROM contactsinfo WHERE id_User=id_User_ AND id_Info=info_id;

      DELETE FROM info WHERE id_Info=info_id;

      SET counter:=counter-1;

    END IF;

  END LOOP info_tableCon;



  DELETE FROM contacts WHERE id_User=id_;#many

  DELETE FROM contacts_his WHERE id_User=id;#many

  DELETE FROM user_his WHERE id_User=id;#many

  DELETE FROM info_his WHERE id_User=id_;#many

  DELETE FROM friendrequest WHERE id_User=id_ OR id_Contact=id_;#many

  DELETE FROM register WHERE id_User=id_;#one

  

  DELETE FROM `user` WHERE id_User=id_;#one

END$$

DROP PROCEDURE IF EXISTS `EXISTS_GROUP`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `EXISTS_GROUP`(id_ INT,name_ INT)
BEGIN

  SELECT COUNT(*) FROM `group`WHERE id_Group=id_ AND `name`=name_;

END$$

DROP PROCEDURE IF EXISTS `EXISTS_MAIL`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `EXISTS_MAIL`(something_ VARCHAR(64))
BEGIN

  SELECT COUNT(*) FROM user WHERE mail=something_;

END$$

DROP PROCEDURE IF EXISTS `EXISTS_USER`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `EXISTS_USER`(something CHAR(32))
BEGIN

  SELECT COUNT(*) FROM `user` WHERE user=something;

END$$

DROP PROCEDURE IF EXISTS `EXISTS_USERTEMP`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `EXISTS_USERTEMP`(something CHAR(32))
BEGIN

  SELECT COUNT(*) FROM usertemp WHERE user=something;

END$$

DROP PROCEDURE IF EXISTS `friendrequest_Invite`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `friendrequest_Invite`(user_ INT,contact_ INT)
BEGIN

  DECLARE yes INT DEFAULT 0;

  SELECT id_user INTO yes FROM friendrequest WHERE id_User=user_ AND id_Contact=contact_;

  IF yes=0 THEN

    INSERT INTO friendrequest (id_User,id_Contact) VALUES (user_,contact_);

  END IF;

END$$

DROP PROCEDURE IF EXISTS `GetContact`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetContact`(idUser_ INT,idContact_ INT)
BEGIN

  DECLARE p,pN,pM TINYINT(2);

  SELECT privacy,name_privacy,mail_privacy INTO p,pN,pM FROM contacts 

  WHERE id_User=idContact_ AND id_Contact=idUser_ LIMIT 1;

  SELECT id_User,user,`name`,mail,p,pN,pM

  FROM vw_contacts

  WHERE contact=idUser_ AND id_User=idContact_

  LIMIT 1;

END$$

DROP PROCEDURE IF EXISTS `GetContacts`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetContacts`(id_ INT)
BEGIN

  SELECT id_User,user,`name`,mail FROM vw_contacts

  WHERE contact=id_ ORDER BY `name`;

END$$

DROP PROCEDURE IF EXISTS `GetContacts_his_mail`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetContacts_his_mail`(id_User_ INT,id_Contact_ INT)
BEGIN

  SELECT DISTINCT mail FROM contacts_his WHERE mail IS NOT NULL AND id_User=id_User_ AND id_Contact=id_Contact_;

END$$

DROP PROCEDURE IF EXISTS `GetContacts_his_name`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetContacts_his_name`(id_User_ INT,id_Contact_ INT)
BEGIN

  SELECT DISTINCT `name` FROM contacts_his WHERE `name` IS NOT NULL AND id_User=id_User_ AND id_Contact=id_Contact_;

END$$

DROP PROCEDURE IF EXISTS `GetFriendRequests`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetFriendRequests`(idUser_ INT)
BEGIN

    SELECT DISTINCT user.id_User,IF(privacy=Privacy_Open(),`user`,'') as user,

                              IF(name_privacy=Privacy_Open(),name,'') as name,

                              IF(mail_privacy=Privacy_Open(),mail,'') as mail

  FROM friendrequest JOIN user using(id_User)

  WHERE id_Contact=idUser_;

END$$

DROP PROCEDURE IF EXISTS `GetGroups_Contact`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetGroups_Contact`(idUser_ INT,idContact_ INT)
BEGIN

  SELECT id_Group,`name`,privacy,name_privacy,mail_privacy

  FROM `group` JOIN contactsgroup using(id_Group)

  WHERE id_User=idUser_ AND id_Contact=idContact_

  ORDER BY `name`;

END$$

DROP PROCEDURE IF EXISTS `GetGroups_Info`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetGroups_Info`(idInfo_ INT)
BEGIN

  SELECT id_Info FROM `group` JOIN groupinfo using(id_Group) WHERE id_Info=idInfo_;

END$$

DROP PROCEDURE IF EXISTS `GetGroups_User`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetGroups_User`(idUser_ INT,name_ VARCHAR(32))
BEGIN

  SET @SQL_=CONCAT('SELECT id_Group,`name`,privacy,name_privacy,mail_privacy FROM `group` WHERE id_User=',

					idUser_,' AND `name` LIKE ''%',

					name_,'%'' collate ',GetLanguage(),' ORDER BY `name`;');

  call SET_VALUES(@SQL_);

END$$

DROP PROCEDURE IF EXISTS `GetInfo_Contact`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetInfo_Contact`(iduser_ INT,idcontact_ INT)
BEGIN

  

  SELECT info.id_Info,info,`type`

  FROM info JOIN userinfo using(id_Info) LEFT JOIN groupinfo using(id_Info)

  WHERE id_User=idcontact_ AND 

  GetPrivacy('info',privacy,IF((SELECT COUNT(1) FROM infocontact WHERE id_Contact=idcontact_ AND id_Info=info.id_Info)=1,1,0),id_Group,info.id_Info)

UNION

  SELECT info.id_Info,info,`type`

  FROM info JOIN contactsinfo using(id_Info)

  WHERE id_User=iduser_ AND id_Contact=idcontact_;

END$$

DROP PROCEDURE IF EXISTS `GetInfo_his_contact`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetInfo_his_contact`(id_User_ INT,id_Contact_ INT)
BEGIN

  SELECT DISTINCT info FROM info_his

  WHERE info IS NOT NULL AND id_User=id_User_ AND id_Contact=id_Contact_;

END$$

DROP PROCEDURE IF EXISTS `GetInfo_his_user`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetInfo_his_user`(id_User_ INT)
BEGIN

  SELECT DISTINCT info FROM info_his

  WHERE info IS NOT NULL AND id_User=id_User_ AND id_Contact IS NULL;

END$$

DROP PROCEDURE IF EXISTS `GetInfo_Privacys`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetInfo_Privacys`(idUser_ INT,idContact_ INT)
BEGIN

  SELECT id_Info FROM userinfo JOIN infocontact using(id_Info)

  WHERE id_Contact=idContact_ AND id_User=idUser_;

END$$

DROP PROCEDURE IF EXISTS `GetInfo_User`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetInfo_User`(iduser_ INT)
BEGIN

  SELECT info.id_Info,info,`type`,privacy

  FROM info JOIN userinfo using(id_Info)

  WHERE id_User=iduser_;

END$$

DROP PROCEDURE IF EXISTS `GetPrivacys`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetPrivacys`(idUser_ INT,idContact_ INT)
BEGIN

  SELECT privacy,name_privacy,mail_privacy

  FROM contacts

  WHERE id_User=idContact_ AND id_Contact=idUser_;

END$$

DROP PROCEDURE IF EXISTS `GetTypes`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetTypes`()
BEGIN

  SELECT DISTINCT `type` FROM info ORDER BY `type`;

END$$

DROP PROCEDURE IF EXISTS `GetUser_BY_Id`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetUser_BY_Id`(id_ INT(32))
BEGIN

  SELECT id_User,user,name,mail,privacy,name_privacy,mail_privacy FROM user WHERE id_User=id_;

END$$

DROP PROCEDURE IF EXISTS `GetUser_BY_User`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetUser_BY_User`(looser CHAR(32))
BEGIN

  SELECT id_User,`user`,`name`,mail,privacy,name_privacy,mail_privacy FROM `user` WHERE `user`=looser COLLATE 'utf8_spanish_ci';

END$$

DROP PROCEDURE IF EXISTS `GetUser_his_mail`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetUser_his_mail`(id_User_ INT)
BEGIN

  SELECT DISTINCT `mail` FROM user_his WHERE mail IS NOT NULL AND id_User=id_User_;

END$$

DROP PROCEDURE IF EXISTS `GetUser_his_name`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetUser_his_name`(id_User_ INT)
BEGIN

  SELECT DISTINCT `name` FROM user_his WHERE `name` IS NOT NULL AND id_User=id_User_;

END$$

DROP PROCEDURE IF EXISTS `GetUser_his_user`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `GetUser_his_user`(id_User_ INT)
BEGIN

  SELECT DISTINCT user FROM user_his WHERE `user` IS NOT NULL AND id_User=id_User_;

END$$

DROP PROCEDURE IF EXISTS `INSERT_GROUP`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `INSERT_GROUP`(name_ VARCHAR(32),privacy_ INT(8),name_privacy_ INT(8),mail_privacy_ INT(8),idUser_ INT)
BEGIN

  INSERT INTO `group`(`name`,privacy,name_privacy,mail_privacy,id_User)

  VALUES(name_,privacy_,name_privacy_,mail_privacy_,idUser_);

END$$

DROP PROCEDURE IF EXISTS `INSERT_INFO_CONTACT`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `INSERT_INFO_CONTACT`(info_ VARCHAR(64),type_ VARCHAR(32),idUser_ INT,idContact_ INT)
BEGIN

  DECLARE idInfo_ INT DEFAULT 0;

  INSERT INTO info(info,`type`) VALUES (info_,type_);

  SELECT id_Info INTO idInfo_ FROM info ORDER BY id_Info DESC LIMIT 1;

  INSERT INTO contactsinfo VALUES(idUser_,idContact_,idInfo_);

END$$

DROP PROCEDURE IF EXISTS `INSERT_INFO_USER`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `INSERT_INFO_USER`(info_ VARCHAR(64),type_ VARCHAR(32),privacy_ TINYINT(2),idUser_ INT)
BEGIN

  DECLARE idInfo_ INT DEFAULT 0;

  INSERT INTO info(info,`type`) VALUES (info_,type_);

  SELECT id_Info INTO idInfo_ FROM info ORDER BY id_Info DESC LIMIT 1;

  INSERT INTO userinfo VALUES(idUser_,idInfo_,privacy_);

END$$

DROP PROCEDURE IF EXISTS `INSERT_LOG`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `INSERT_LOG`(site_ VARCHAR(32),tabla_ VARCHAR(16),transaction_ VARCHAR(128),description_ VARCHAR(512), stackTrace_ VARCHAR(512), details_ VARCHAR(256))
BEGIN

  INSERT INTO agendix.error(site,tabla,transaction,description,stackTrace,details) 

				 VALUES(site_,tabla_,transaction_,description_,stackTrace_,details_);

END$$

DROP PROCEDURE IF EXISTS `joinContactToGroup`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `joinContactToGroup`(idContact_ INT,idGroup_ INT)
BEGIN

  DECLARE existe INT DEFAULT 0;

  SELECT COUNT(*) INTO existe FROM contactsgroup WHERE id_Contact=idContact_ AND id_Group=idGroup_;

  IF existe=0 THEN

    INSERT INTO contactsgroup VALUES(idContact_,idGroup_);

  ELSE

	DELETE FROM contactsgroup WHERE id_Contact=idContact_ AND id_Group=idGroup_;

  END IF;

END$$

DROP PROCEDURE IF EXISTS `joinInfoToGroup`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `joinInfoToGroup`(idGroup_ INT,idInfo_ INT)
BEGIN

  DECLARE existe INT DEFAULT 0;

  SELECT COUNT(*) INTO existe FROM groupinfo WHERE id_Group=idGroup_ AND id_Info=idInfo_;

  IF existe=0 THEN

    INSERT INTO groupinfo VALUES(idGroup_,idInfo_);

  ELSE

	DELETE FROM groupinfo WHERE id_Group=idGroup_ AND id_Info=idInfo_;

  END IF;

END$$

DROP PROCEDURE IF EXISTS `register_change`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `register_change`(id_ INT,old_ CHAR(128),pass_ CHAR(128))
BEGIN

  DECLARE cont INT(32) DEFAULT -1;

  SELECT COUNT(*) INTO cont FROM register WHERE id_User=id_ AND pass=old_;

  IF cont=1 THEN

    UPDATE register SET pass=pass_ WHERE id_User=id_;

  END IF;

  SELECT cont;

END$$

DROP PROCEDURE IF EXISTS `REJECT_CONTACT`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `REJECT_CONTACT`(id_User_ INT(32),id_Contact_ INT(32))
BEGIN

  call DELETE_CONTACT(id_User_,id_Contact_);

END$$

DROP PROCEDURE IF EXISTS `restore_contact`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `restore_contact`(user_ INT(32),contact_ INT(32))
BEGIN

  INSERT INTO contacts(`id_User`,`id_Contact`) VALUES (user_,contact_);

END$$

DROP PROCEDURE IF EXISTS `SetInfo_Privacy`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `SetInfo_Privacy`(idInfo_ INT,idContact_ INT)
BEGIN

  INSERT INTO infocontact VALUES(idInfo_,idContact_);

END$$

DROP PROCEDURE IF EXISTS `SET_VALUES`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `SET_VALUES`(cad VARCHAR(1024))
BEGIN

  SET @q=cad;

  PREPARE smpt FROM @q;

  EXECUTE smpt;

  DEALLOCATE PREPARE smpt;

END$$

DROP PROCEDURE IF EXISTS `ShowLog`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `ShowLog`(IN `tipo_` VARCHAR(32))
    READS SQL DATA
    SQL SECURITY INVOKER
SELECT * FROM Development_log

WHERE sitio=tipo_

ORDER BY idDevelopment_log$$

DROP PROCEDURE IF EXISTS `trazar`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `trazar`(IN sitio_ VARCHAR(32),IN dato_ VARCHAR(32),IN valor_ VARCHAR(255),IN issue_number_ INT)
BEGIN

  INSERT INTO Development_log(sitio,dato,valor,issue_number) VALUES(sitio_,dato_,valor_,issue_number_);

END$$

DROP PROCEDURE IF EXISTS `UPDATE_CONTACT`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `UPDATE_CONTACT`(idContact_ INT,privacy_ TINYINT(8),name_ VARCHAR(32),name_privacy_ TINYINT(8),
									  mail_ VARCHAR(64),mail_privacy_ TINYINT(8),idUser_ INT)
BEGIN
  UPDATE contacts SET `name`=name_,`name_privacy`=name_privacy_,`mail`=mail_,`mail_privacy`=mail_privacy_,`privacy`=privacy_
  WHERE id_User=idUser_ AND id_Contact=idContact_;
END$$

DROP PROCEDURE IF EXISTS `UPDATE_CONTACT_DYN`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `UPDATE_CONTACT_DYN`(idContact_ INT,privacy_ TINYINT(8),name_ VARCHAR(32),name_privacy_ TINYINT(8),mail_ VARCHAR(64),mail_privacy_ TINYINT(8),idUser_ INT)
BEGIN

  DECLARE StrQuery VARCHAR(255) DEFAULT 'UPDATE `contacts` SET ';

  DECLARE StrHis1 VARCHAR(128) DEFAULT '`id_User`,`id_Contact`';

  DECLARE StrHis2 VARCHAR(128) DEFAULT CONCAT('VALUES(',idUser_,',',idContact_);

  DECLARE StrQueryHis VARCHAR(255) DEFAULT 'INSERT INTO contacts_his(';



  call BuildQuery('name',name_,'contacts',CONCAT('id_User=',idUser_,' AND id_Contact=',idContact_),StrHis1,StrHis2,StrQuery);

  call BuildQuery('mail',mail_,'contacts',CONCAT('id_User=',idUser_,' AND id_Contact=',idContact_),StrHis1,StrHis2,StrQuery);



  IF LENGTH(StrHis1)>25 THEN

    SET StrHis1=CONCAT(StrHis1,') ');

    SET StrHis2=CONCAT(StrHis2,');');

    call SET_VALUES(CONCAT(StrQueryHis,StrHis1,StrHis2));

  END IF;



  IF LENGTH(StrQuery)>25 THEN

    SET StrQuery=SUBSTR(StrQuery,1,CHAR_LENGTH(StrQuery)-1);

    call SET_VALUES(CONCAT(StrQuery,' WHERE id_User=',idUser_,' AND id_Contact=',idContact_));

    SET StrQuery='UPDATE `contacts` SET ';

  END IF;

  call BuildPrivacy(privacy_,name_privacy_,mail_privacy_,'contacts',CONCAT('id_User=',idContact_,' AND id_Contact=',idUser_),StrQuery);

  IF LENGTH(StrQuery)>25 THEN

    SET StrQuery=SUBSTR(StrQuery,1,CHAR_LENGTH(StrQuery)-1);

    call SET_VALUES(CONCAT(StrQuery,' WHERE id_User=',idContact_,' AND id_Contact=',idUser_));

  END IF;

#call trazar('UPDATE_CONTACT','Terminó',StrQuery,50);

END$$

DROP PROCEDURE IF EXISTS `UPDATE_GROUP`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `UPDATE_GROUP`(idGroup_ INT,name_ VARCHAR(32),privacy_ INT(8),name_privacy_ INT(8),mail_privacy_ INT(8))
BEGIN

  UPDATE `group` SET `name`=name_,privacy=privacy_,name_privacy=name_privacy_,mail_privacy=mail_privacy_

  WHERE id_Group=idGroup_;

END$$

DROP PROCEDURE IF EXISTS `UPDATE_INFO_CONTACT`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `UPDATE_INFO_CONTACT`(id_ INT,info_ VARCHAR(64),type_ VARCHAR(32))
BEGIN

  DECLARE idUser_ INT(32) DEFAULT 0;

  DECLARE idContact_ INT(32) DEFAULT 0;

  DECLARE _info VARCHAR(64);

  DECLARE field VARCHAR(64);



  SELECT info INTO _info FROM info WHERE id_Info=id_;

  IF _info != info_ THEN

    SELECT id_User,id_Contact INTO idUser_,idContact_ FROM contactsinfo WHERE id_Info=id_ LIMIT 1;

	SELECT info INTO field FROM info_his WHERE id_User=idUser_ AND id_Contact=idContact_ AND info=_info LIMIT 1;

	IF field IS NULL THEN

	  INSERT INTO info_his(id_User,id_Contact,info) VALUES (idUser_,idContact_,_info);

	END IF;

    UPDATE info SET info=info_,`type`=type_ WHERE id_Info=id_;

  ELSE

    UPDATE info SET `type`=type_ WHERE id_Info=id_;

  END IF;

#call trazar('UPDATE_INFO_CONTACT','field: ',field,21);

END$$

DROP PROCEDURE IF EXISTS `UPDATE_INFO_USER`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `UPDATE_INFO_USER`(id_ INT(32),info_ VARCHAR(64),privacy_ TINYINT(8),type_ VARCHAR(32))
BEGIN

  DECLARE idUser_ INT(32) DEFAULT 0;

  DECLARE _info VARCHAR(64);

  DECLARE _privacy INT(8);

  DECLARE field VARCHAR(64);



  SELECT info INTO _info FROM info WHERE id_Info=id_;

  SELECT id_User INTO idUser_ FROM userinfo WHERE id_Info=id_;

  IF _info != info_ THEN

	SELECT info INTO field FROM info_his WHERE id_User=idUser_ AND id_Contact IS NULL;

	IF field IS NULL OR _info!=field THEN

	  INSERT INTO info_his(id_User,info) VALUES (idUser_,_info);

	END IF;

    UPDATE info SET info=info_,`type`=type_ WHERE id_Info=id_;

  ELSE

    UPDATE info SET `type`=type_ WHERE id_Info=id_;

  END IF;

  SELECT privacy INTO _privacy FROM userinfo WHERE id_Info=id_;

  IF _privacy<>privacy_ THEN

	UPDATE userinfo SET privacy=privacy_ WHERE id_Info=id_;

  END IF;

#call trazar('UPDATE_INFO_USER','_privacy: ',_privacy,31);

END$$

DROP PROCEDURE IF EXISTS `UPDATE_USER`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `UPDATE_USER`(id_ INT(32),user_ VARCHAR(32),privacy_ INT(8),name_ VARCHAR(32),
									name_privacy_ INT(8),mail_ VARCHAR(128),mail_privacy_ INT(8))
BEGIN
  UPDATE `user` SET `user`=user_,`name`=name_,`name_privacy`=name_privacy_,
  `mail`=mail_,`mail_privacy`=mail_privacy_,`privacy`=privacy_
  WHERE id_User=id_;
END$$

DROP PROCEDURE IF EXISTS `UPDATE_USER_DYN`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `UPDATE_USER_DYN`(id_ INT(32),user_ VARCHAR(32),privacy_ INT(8),

name_ VARCHAR(32),name_privacy_ INT(8),mail_ VARCHAR(128),mail_privacy_ INT(8))
BEGIN

  DECLARE StrQuery VARCHAR(255) DEFAULT 'UPDATE `user` SET ';

  DECLARE StrHis1 VARCHAR(255) DEFAULT '`id_User`';

  DECLARE StrHis2 VARCHAR(255) DEFAULT CONCAT('VALUES(',id_);

  DECLARE StrQueryHis VARCHAR(255) DEFAULT 'INSERT INTO user_his(';

  

  call BuildQuery('user',user_,'user',CONCAT('id_User=',id_),StrHis1,StrHis2,StrQuery);

  call BuildQuery('name',name_,'user',CONCAT('id_User=',id_),StrHis1,StrHis2,StrQuery);

  call BuildQuery('mail',mail_,'user',CONCAT('id_User=',id_),StrHis1,StrHis2,StrQuery);

  IF LENGTH(StrHis1)>11 THEN

    SET StrHis1=CONCAT(StrHis1,') ');

    SET StrHis2=CONCAT(StrHis2,');');

    call SET_VALUES(CONCAT(StrQueryHis,StrHis1,StrHis2));

  END IF;

  call BuildPrivacy(privacy_,name_privacy_,mail_privacy_,'user',CONCAT('id_User=',id_),StrQuery);

  SET StrQuery=SUBSTR(StrQuery,1,CHAR_LENGTH(StrQuery)-1);

  call SET_VALUES(CONCAT(StrQuery,' WHERE id_User=',id_));

#call trazar('UPDATE_USER','@StrQuery',@StrQuery,41);

END$$

DROP PROCEDURE IF EXISTS `usertemp_GetId`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `usertemp_GetId`(user_ CHAR(32))
BEGIN

  SELECT id FROM usertemp WHERE user=user_;

END$$

DROP PROCEDURE IF EXISTS `usertemp_New`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `usertemp_New`(userNew CHAR(32),passNew CHAR(128),mailNew VARCHAR(128),name_new VARCHAR(32),phone_new VARCHAR(24))
BEGIN

  INSERT INTO `userTemp` (`user`,`name`,mail,phone,`sign_date`,`key`) VALUES (userNew,name_new,mailNew,phone_new,CURDATE(),passNew);

END$$

DROP PROCEDURE IF EXISTS `usertemp_TO_user`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `usertemp_TO_user`(id_ INT(32))
BEGIN

  DECLARE iduser_ INT(32);

  DECLARE user_ CHAR(32);

  DECLARE mail_ VARCHAR(64);

  DECLARE phone_ VARCHAR(24);

  DECLARE name_ VARCHAR(32);

  DECLARE key_ CHAR(128);

  DECLARE id_Info_ INT(32);

  SELECT `user`,name,mail,phone,`key` INTO user_,name_,mail_,phone_,key_ FROM usertemp WHERE id=id_ LIMIT 1;

  INSERT INTO `user`(user,name,mail) VALUES (user_,name_,mail_);

  SELECT id_User INTO iduser_ FROM user WHERE user=user_ LIMIT 1;

  IF phone_ IS NOT NULL AND phone_ <> '' THEN

    INSERT INTO info(info,type) VALUES (phone_,'Teléfono principal');

    SELECT MAX(id_Info) INTO id_Info_ FROM info LIMIT 1;

    INSERT INTO userinfo VALUES(iduser_,id_Info_,2);

  END IF;

  INSERT INTO register VALUES (iduser_,key_,1);

  DELETE FROM usertemp WHERE id=id_;

END$$

DROP PROCEDURE IF EXISTS `user_Cast`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `user_Cast`(id INT,pw CHAR(128))
BEGIN

  SELECT COUNT(*) FROM register WHERE id_User=id AND pass=IFNULL(

pw,

'mal') AND active=1;

END$$

DROP PROCEDURE IF EXISTS `user_GetId`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `user_GetId`(user_ CHAR)
BEGIN

  SELECT id_User FROM user WHERE user=user_;

END$$

DROP PROCEDURE IF EXISTS `user_getLastInserted`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `user_getLastInserted`()
BEGIN

  SELECT id_User,user,name,mail,privacy,name_privacy,mail_privacy FROM user ORDER BY id_User DESC LIMIT 1;

END$$

DROP PROCEDURE IF EXISTS `user_Search`$$
CREATE DEFINER=`Jahiag_user`@`localhost` PROCEDURE `user_Search`(idUser_ INT,text_ VARCHAR(32))
BEGIN

  SET @SQL_=CONCAT('

  SELECT DISTINCT user.id_User,IF(user.privacy=Privacy_Open(),user,'''') as user,

                              IF(user.name_privacy=Privacy_Open(),user.name,'''') as name,

                              IF(user.mail_privacy=Privacy_Open(),user.mail,'''') as mail

  FROM user 

  WHERE user.id_User<>',idUser_,'

  AND user.id_User NOT IN (

	SELECT DISTINCT user.id_User 

	FROM user JOIN contacts ON user.id_User=id_Contact 

	WHERE contacts.id_User=',idUser_,'

	)

  AND (

  (user.user LIKE ''%',text_,'%'' collate ',GetLanguage(),' AND user.privacy=Privacy_Open()) OR

  (user.name LIKE ''%',text_,'%'' collate ',GetLanguage(),' AND user.name_privacy=Privacy_Open()) OR

  (SUBSTRING_INDEX(user.mail,''@'',1) LIKE ''%',text_,'%'' AND user.mail_privacy=Privacy_Open()) OR

  user.id_User IN (

	SELECT DISTINCT id_User 

	FROM userinfo JOIN info using(id_Info)

	WHERE info LIKE ''%',text_,'%'' collate ',GetLanguage(),' AND privacy=Privacy_Open()

	)

);');

  call SET_VALUES(@SQL_);

END$$

--
-- Funciones
--
DROP FUNCTION IF EXISTS `GetLanguage`$$
CREATE DEFINER=`Jahiag_user`@`localhost` FUNCTION `GetLanguage`() RETURNS varchar(32) CHARSET utf8 COLLATE utf8_bin
    DETERMINISTIC
BEGIN

  RETURN 'utf8_spanish_ci';

END$$

DROP FUNCTION IF EXISTS `GetPrivacy`$$
CREATE DEFINER=`Jahiag_user`@`localhost` FUNCTION `GetPrivacy`(np VARCHAR(16),p INT(8),cp INT(2),idUser_ INT,idContact_ INT) RETURNS tinyint(1)
    READS SQL DATA
BEGIN

  RETURN p = Privacy_Open()

	  OR (p = Privacy_Restricted() AND cp = 1)

	  OR (p = Privacy_Grupped() AND groupAllows(np,idUser_,idContact_));

END$$

DROP FUNCTION IF EXISTS `groupAllows`$$
CREATE DEFINER=`Jahiag_user`@`localhost` FUNCTION `groupAllows`(np VARCHAR(16),idUser_ INT,idContact_ INT) RETURNS tinyint(1)
    READS SQL DATA
BEGIN

  DECLARE result TINYINT(1) DEFAULT 0;

  SET @res :=0;

  IF np='p' THEN

	SELECT 1 INTO @res FROM contactsgroup JOIN `group` using(id_group)

	WHERE id_User=idContact_ AND id_Contact=idUser_ AND privacy=1 LIMIT 1;

  ELSE

    IF np='pN' THEN

	  SELECT 1 INTO @res FROM contactsgroup JOIN `group` using(id_group)

	  WHERE id_User=idContact_ AND id_Contact=idUser_ AND name_privacy=1 LIMIT 1;

	ELSE

	  IF np='pM' THEN

	    SELECT 1 INTO @res FROM contactsgroup JOIN `group` using(id_group)

	    WHERE id_User=idContact_ AND id_Contact=idUser_ AND mail_privacy=1 LIMIT 1;

	  ELSE# info_privacy

		SELECT 1 INTO @res FROM groupinfo

		WHERE idUser_ IS NOT NULL AND id_Group=idUser_ AND id_Info=idContact_;

	  END IF;

	END IF;

  END IF;

#call trazar('groupAllows','@q',@q,30);

  SET result := @res;

  RETURN result;

END$$

DROP FUNCTION IF EXISTS `Privacy_Grupped`$$
CREATE DEFINER=`Jahiag_user`@`localhost` FUNCTION `Privacy_Grupped`() RETURNS int(11)
    DETERMINISTIC
BEGIN

  RETURN 1;

END$$

DROP FUNCTION IF EXISTS `Privacy_Open`$$
CREATE DEFINER=`Jahiag_user`@`localhost` FUNCTION `Privacy_Open`() RETURNS int(11)
    DETERMINISTIC
BEGIN

  RETURN 3;

END$$

DROP FUNCTION IF EXISTS `Privacy_Personal`$$
CREATE DEFINER=`Jahiag_user`@`localhost` FUNCTION `Privacy_Personal`() RETURNS int(11)
    DETERMINISTIC
BEGIN

  RETURN 0;

END$$

DROP FUNCTION IF EXISTS `Privacy_Restricted`$$
CREATE DEFINER=`Jahiag_user`@`localhost` FUNCTION `Privacy_Restricted`() RETURNS int(11)
    DETERMINISTIC
BEGIN

  RETURN 2;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `contacts`
--

DROP TABLE IF EXISTS `contacts`;
CREATE TABLE IF NOT EXISTS `contacts` (
  `id_User` int(32) NOT NULL,
  `id_Contact` int(32) NOT NULL,
  `name` varchar(32) CHARACTER SET utf8 DEFAULT NULL,
  `name_privacy` tinyint(2) DEFAULT '0',
  `mail` varchar(64) CHARACTER SET utf8 DEFAULT NULL,
  `mail_privacy` tinyint(2) DEFAULT '0',
  `privacy` tinyint(2) NOT NULL DEFAULT '0',
  KEY `idUser` (`id_User`),
  KEY `Agenda` (`id_User`,`id_Contact`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `contacts`
--

INSERT INTO `contacts` (`id_User`, `id_Contact`, `name`, `name_privacy`, `mail`, `mail_privacy`, `privacy`) VALUES
(2, 3, 'Olalla Al', 1, 'olinoki@hotmail.com', 1, 1),
(2, 4, 'Rixi', 1, NULL, 1, 1),
(2, 6, 'Javi García Sánchez-Valdepeñas', 0, '', 1, 0),
(2, 7, 'Sebax', 0, 'sebasce@gmail.com', 0, 1),
(3, 2, 'Maridito', 1, '', 1, 1),
(3, 6, 'Javi Sara', 1, NULL, 1, 1),
(3, 7, 'Sebas Tián', 1, NULL, 1, 1),
(4, 2, NULL, 1, NULL, 1, 1),
(2, 13, 'Uli', 1, 'ulisesdg@hotmail.com', 0, 0),
(5, 7, 'Sebas', 0, '', 0, 0),
(3, 5, 'Alberto Gonz', 0, '', 0, 0),
(5, 2, 'Abel', 1, NULL, 1, 1),
(16, 2, 'Hailcht!', 0, NULL, 0, 0),
(16, 7, 'Sebas', 0, NULL, 0, 0),
(16, 8, 'Tomax', 1, NULL, 0, 1),
(5, 16, 'Carlos Roncero', 1, NULL, 0, 0),
(16, 5, 'PeTi', 0, NULL, 0, 0),
(4, 16, NULL, 1, NULL, 0, 0),
(16, 4, 'Richi', 0, NULL, 0, 0),
(2, 15, 'mamá', 1, 'mamadeabel@gmail.com', 0, 0),
(5, 15, 'madre abel', 1, NULL, 0, 1),
(3, 16, 'Carlos Roncero', 0, 'charlydejm@hotmail.com', 0, 0),
(16, 3, NULL, 1, NULL, 0, 0),
(3, 15, 'Celia', 1, NULL, 0, 0),
(3, 14, 'RGQ', 0, '', 0, 0),
(2, 14, 'RGQ', 0, 'rastar20@hotmail.com', 1, 1),
(16, 14, NULL, 0, NULL, 0, 0),
(3, 4, NULL, 0, NULL, 0, 0),
(4, 3, NULL, 0, NULL, 0, 0),
(5, 4, NULL, 0, NULL, 0, 0),
(4, 5, NULL, 0, NULL, 0, 0),
(2, 8, 'Tomasín', 0, '', 0, 0),
(2, 5, 'Peti', 1, 'betitoglez@gmail.com', 0, 0),
(2, 16, 'Carlos Roncero', 0, '', 0, 0),
(4, 13, NULL, 0, NULL, 0, 0),
(16, 13, NULL, 0, NULL, 0, 0),
(5, 8, NULL, 0, NULL, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `contactsgroup`
--

DROP TABLE IF EXISTS `contactsgroup`;
CREATE TABLE IF NOT EXISTS `contactsgroup` (
  `id_Contact` int(32) NOT NULL,
  `id_Group` int(32) NOT NULL,
  PRIMARY KEY (`id_Contact`,`id_Group`),
  KEY `id_Group` (`id_Group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `contactsgroup`
--

INSERT INTO `contactsgroup` (`id_Contact`, `id_Group`) VALUES
(6, 1),
(7, 1),
(8, 1),
(16, 1),
(4, 2),
(5, 2),
(13, 2),
(16, 2),
(3, 4),
(15, 4),
(6, 5),
(7, 5),
(4, 6),
(5, 6),
(6, 6),
(7, 6),
(8, 6),
(16, 6),
(14, 8),
(2, 9),
(2, 12);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `contactsinfo`
--

DROP TABLE IF EXISTS `contactsinfo`;
CREATE TABLE IF NOT EXISTS `contactsinfo` (
  `id_User` int(32) NOT NULL,
  `id_Contact` int(32) NOT NULL,
  `id_Info` int(32) NOT NULL,
  KEY `id_User` (`id_User`,`id_Contact`,`id_Info`),
  KEY `id_Info` (`id_Info`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `contactsinfo`
--

INSERT INTO `contactsinfo` (`id_User`, `id_Contact`, `id_Info`) VALUES
(2, 3, 1),
(2, 14, 35),
(2, 15, 9),
(3, 2, 7),
(3, 5, 16),
(5, 2, 18),
(5, 16, 31),
(16, 2, 13),
(16, 2, 32),
(16, 5, 12),
(16, 8, 14);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `contacts_his`
--

DROP TABLE IF EXISTS `contacts_his`;
CREATE TABLE IF NOT EXISTS `contacts_his` (
  `id_User` int(32) NOT NULL,
  `id_Contact` int(32) NOT NULL,
  `name` varchar(32) CHARACTER SET utf8 DEFAULT NULL,
  `mail` varchar(64) CHARACTER SET utf8 DEFAULT NULL,
  KEY `contacts_his_id` (`id_User`,`id_Contact`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `contacts_his`
--

INSERT INTO `contacts_his` (`id_User`, `id_Contact`, `name`, `mail`) VALUES
(2, 13, NULL, ''),
(2, 8, 'tom', NULL),
(2, 8, 'tomas', NULL),
(2, 8, 'Tomasín', NULL),
(3, 14, 'nombre_raro', 'correo@raro.es'),
(2, 16, 'Carlos Roncero', NULL),
(2, 16, 'nombre_raro', 'correo@raro.es'),
(2, 5, 'nombre_raro', 'correo@raro.es'),
(16, 8, 'Tomás', NULL),
(2, 16, NULL, ''),
(3, 14, '', NULL),
(2, 14, 'RGQ', NULL),
(2, 14, '', NULL),
(2, 5, 'Peti', 'betitoglez@gmail.com'),
(2, 5, 'Petirrojo', 'betitogle@gmail.com'),
(2, 14, 'Rulo', NULL),
(2, 3, 'Olalla Al', NULL),
(3, 2, 'Maridito', 'abel.fincias@gmail.com'),
(2, 3, 'Amorcito', NULL),
(3, 2, 'Olalla Al', 'olinoki@hotmail.com'),
(2, 8, 'TomÃ¡s', NULL),
(2, 8, 'TomasÃ­n', NULL),
(2, 6, 'Javi García', NULL),
(2, 6, 'Javi García Sánchez-Valdepeña', NULL),
(2, 16, 'roncerdo', NULL),
(2, 6, 'Javi García Sánchez-Valdepeñas', NULL),
(2, 6, 'Javi Sánchez-Valdepeñas', NULL),
(3, 14, 'no se quien es', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `development_log`
--

DROP TABLE IF EXISTS `development_log`;
CREATE TABLE IF NOT EXISTS `development_log` (
  `idDevelopment_log` int(32) NOT NULL AUTO_INCREMENT,
  `sitio` varchar(32) COLLATE utf8_spanish_ci DEFAULT NULL,
  `dato` varchar(32) COLLATE utf8_spanish_ci DEFAULT NULL,
  `valor` varchar(255) COLLATE utf8_spanish_ci DEFAULT NULL,
  `Issue_number` int(8) DEFAULT '0',
  `fecha` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idDevelopment_log`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=18143 ;

--
-- Volcado de datos para la tabla `development_log`
--

INSERT INTO `development_log` (`idDevelopment_log`, `sitio`, `dato`, `valor`, `Issue_number`, `fecha`) VALUES
(18138, 'UPDATE_CONTACT', 'entra', 'RGQ', 10, '2014-05-20 09:28:19'),
(18139, 'UPDATE_CONTACT', 'entra', 'RGQ', 10, '2014-05-20 09:31:09'),
(18140, 'UPDATE_CONTACT', 'entra', 'RGQ', 10, '2014-05-20 09:31:28'),
(18141, 'UPDATE_CONTACT', 'entra', 'Rulo', 10, '2014-05-20 10:38:07'),
(18142, 'UPDATE_CONTACT', 'entra', 'poyas', 10, '2014-05-20 10:40:26');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `error`
--

DROP TABLE IF EXISTS `error`;
CREATE TABLE IF NOT EXISTS `error` (
  `id_error` int(32) NOT NULL AUTO_INCREMENT,
  `fail_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `site` varchar(32) COLLATE utf8_spanish_ci NOT NULL,
  `tabla` varchar(16) COLLATE utf8_spanish_ci DEFAULT NULL,
  `transaction` varchar(128) COLLATE utf8_spanish_ci NOT NULL,
  `description` varchar(512) COLLATE utf8_spanish_ci DEFAULT NULL,
  `stackTrace` varchar(512) COLLATE utf8_spanish_ci DEFAULT NULL,
  `details` varchar(256) COLLATE utf8_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`id_error`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci COMMENT='contiene errores de base de datos' AUTO_INCREMENT=658 ;

--
-- Volcado de datos para la tabla `error`
--

INSERT INTO `error` (`id_error`, `fail_date`, `site`, `tabla`, `transaction`, `description`, `stackTrace`, `details`) VALUES
(654, '2015-09-17 10:03:50', 'InvokeMethod', '', '0 ?looser', 'Unknown data type', '   en Microsoft.VisualBasic.CompilerServices.Symbols.Container.InvokeMethod(Method TargetProcedure, Object[] Arguments, Boolean[] CopyBack, BindingFlags Flags)\r\n   en Microsoft.VisualBasic.CompilerServices.NewLateBinding.LateSet(Object Instance, Type Type, String MemberName, Object[] Arguments, String[] ArgumentNames, Type[] TypeArguments, Boolean OptimisticSet, Boolean RValueBase, CallType CallType)\r\n   en Microsoft.VisualBasic.CompilerServices.NewLateBinding.LateSetComplex(Object Instance, Type Type, Str', ''),
(655, '2015-09-17 10:03:50', 'GetProcData', '', 'GetUser_BY_User(?looser);', 'Procedure or function ''`GetUser_BY_User(?looser)`'' cannot be found in database ''`agendix`''.', '   en MySql.Data.MySqlClient.ProcedureCache.GetProcData(MySqlConnection connection, String spName)\r\n   en MySql.Data.MySqlClient.ProcedureCache.AddNew(MySqlConnection connection, String spName)\r\n   en MySql.Data.MySqlClient.ProcedureCache.GetProcedure(MySqlConnection conn, String spName, String cacheKey)\r\n   en MySql.Data.MySqlClient.StoredProcedure.GetParameters(String procName, DataTable& proceduresTable, DataTable& parametersTable)\r\n   en MySql.Data.MySqlClient.StoredProcedure.CheckParameters(String spN', ''),
(656, '2015-09-17 10:04:00', 'InvokeMethod', '', '0 ?looser', 'Unknown data type', '   en Microsoft.VisualBasic.CompilerServices.Symbols.Container.InvokeMethod(Method TargetProcedure, Object[] Arguments, Boolean[] CopyBack, BindingFlags Flags)\r\n   en Microsoft.VisualBasic.CompilerServices.NewLateBinding.LateSet(Object Instance, Type Type, String MemberName, Object[] Arguments, String[] ArgumentNames, Type[] TypeArguments, Boolean OptimisticSet, Boolean RValueBase, CallType CallType)\r\n   en Microsoft.VisualBasic.CompilerServices.NewLateBinding.LateSetComplex(Object Instance, Type Type, Str', ''),
(657, '2015-09-17 10:04:00', 'GetProcData', '', 'GetUser_BY_User(?looser);', 'Procedure or function ''`GetUser_BY_User(?looser)`'' cannot be found in database ''`agendix`''.', '   en MySql.Data.MySqlClient.ProcedureCache.GetProcData(MySqlConnection connection, String spName)\r\n   en MySql.Data.MySqlClient.ProcedureCache.AddNew(MySqlConnection connection, String spName)\r\n   en MySql.Data.MySqlClient.ProcedureCache.GetProcedure(MySqlConnection conn, String spName, String cacheKey)\r\n   en MySql.Data.MySqlClient.StoredProcedure.GetParameters(String procName, DataTable& proceduresTable, DataTable& parametersTable)\r\n   en MySql.Data.MySqlClient.StoredProcedure.CheckParameters(String spN', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `friendrequest`
--

DROP TABLE IF EXISTS `friendrequest`;
CREATE TABLE IF NOT EXISTS `friendrequest` (
  `id_User` int(32) NOT NULL,
  `id_Contact` int(32) NOT NULL,
  KEY `users` (`id_User`,`id_Contact`),
  KEY `id_Contact` (`id_Contact`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `group`
--

DROP TABLE IF EXISTS `group`;
CREATE TABLE IF NOT EXISTS `group` (
  `id_Group` int(32) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) CHARACTER SET utf8 NOT NULL,
  `privacy` tinyint(1) NOT NULL DEFAULT '0',
  `name_privacy` tinyint(1) NOT NULL DEFAULT '0',
  `mail_privacy` tinyint(1) NOT NULL DEFAULT '0',
  `id_User` int(32) NOT NULL,
  PRIMARY KEY (`id_Group`),
  KEY `id_User_idx` (`id_User`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=15 ;

--
-- Volcado de datos para la tabla `group`
--

INSERT INTO `group` (`id_Group`, `name`, `privacy`, `name_privacy`, `mail_privacy`, `id_User`) VALUES
(1, 'Nombre', 0, 1, 0, 2),
(2, 'Correo', 0, 0, 1, 2),
(3, 'User', 1, 0, 0, 2),
(4, 'Familia', 1, 1, 1, 2),
(5, 'Amigos', 1, 1, 1, 3),
(6, 'Amigos Abel', 0, 1, 0, 3),
(8, 'Amigos', 1, 1, 1, 2),
(9, 'familia', 1, 1, 1, 3),
(12, 'EUI', 1, 1, 1, 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `groupinfo`
--

DROP TABLE IF EXISTS `groupinfo`;
CREATE TABLE IF NOT EXISTS `groupinfo` (
  `id_Group` int(32) NOT NULL,
  `id_Info` int(32) NOT NULL,
  PRIMARY KEY (`id_Group`,`id_Info`),
  KEY `id_Info` (`id_Info`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `groupinfo`
--

INSERT INTO `groupinfo` (`id_Group`, `id_Info`) VALUES
(1, 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `info`
--

DROP TABLE IF EXISTS `info`;
CREATE TABLE IF NOT EXISTS `info` (
  `id_Info` int(32) NOT NULL AUTO_INCREMENT,
  `info` varchar(64) CHARACTER SET utf8 NOT NULL,
  `type` varchar(32) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id_Info`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=36 ;

--
-- Volcado de datos para la tabla `info`
--

INSERT INTO `info` (`id_Info`, `info`, `type`) VALUES
(1, '912456239', 'Telefono de casa'),
(2, 'Raúl García-Quiñones', 'Nick'),
(3, 'abel.fincias@tic.alten.es', 'Correo del trabajo'),
(4, 'propagandainteresante@gmail.com', 'mail de propaganda'),
(7, '616375688', 'movil curro'),
(8, '605457893', 'Teléfono principal'),
(9, '660282060', 'Móvil'),
(12, '915748990', 'Teléfono de casa'),
(13, 'abelkla@gmail.com', 'Correo'),
(14, 'Tomasturbado', 'Nick'),
(16, '915748990', 'Teléfono de casa'),
(17, '915743694', 'Teléfono de casa'),
(18, '616375688', 'Móvil'),
(23, '647546647', 'Teléfono Móvil'),
(24, '652644356', 'Teléfono Móvil'),
(25, '605487923', 'Teléfono Móvil'),
(31, 'otra vez el mismo', 'Teléfono de casa'),
(32, '616375688', 'Móvil'),
(33, '652644356', 'Móvil'),
(34, '669190093', 'Móvil'),
(35, 'Raúl', 'Nick');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `infocontact`
--

DROP TABLE IF EXISTS `infocontact`;
CREATE TABLE IF NOT EXISTS `infocontact` (
  `id_Info` int(32) NOT NULL,
  `id_Contact` int(32) NOT NULL,
  PRIMARY KEY (`id_Info`,`id_Contact`),
  KEY `id_Info_idx` (`id_Info`),
  KEY `id_Contact_idx` (`id_Contact`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `infocontact`
--

INSERT INTO `infocontact` (`id_Info`, `id_Contact`) VALUES
(3, 3),
(3, 16),
(4, 3),
(4, 16);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `info_his`
--

DROP TABLE IF EXISTS `info_his`;
CREATE TABLE IF NOT EXISTS `info_his` (
  `id_User` int(32) NOT NULL,
  `id_Contact` int(32) DEFAULT NULL,
  `info` varchar(64) CHARACTER SET utf8 NOT NULL,
  KEY `info_his_id` (`id_User`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `info_his`
--

INSERT INTO `info_his` (`id_User`, `id_Contact`, `info`) VALUES
(3, 2, '652643356'),
(2, 3, 'quiñones'),
(3, 16, '917593694'),
(3, 16, '605789436'),
(3, 16, '917543694'),
(2, 5, 'quiñones');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `migrations`
--

DROP TABLE IF EXISTS `migrations`;
CREATE TABLE IF NOT EXISTS `migrations` (
  `migration` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `migrations`
--

INSERT INTO `migrations` (`migration`, `batch`) VALUES
('2014_10_12_000000_create_users_table', 1),
('2014_10_12_100000_create_password_resets_table', 1),
('2016_09_07_124539_create_bookings_table', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
CREATE TABLE IF NOT EXISTS `password_resets` (
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  KEY `password_resets_email_index` (`email`),
  KEY `password_resets_token_index` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `password_resets`
--

INSERT INTO `password_resets` (`email`, `token`, `created_at`) VALUES
('olinoki@hotmail.com', 'ba291a77ced499f7ea73ca707a83c5192d12ec1c272bb114a75b5ed724177c31', '2016-09-07 13:34:27');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
  `id_User` int(32) NOT NULL AUTO_INCREMENT,
  `user` char(32) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(32) CHARACTER SET utf8 NOT NULL,
  `name_privacy` tinyint(8) NOT NULL DEFAULT '0',
  `mail` varchar(64) CHARACTER SET utf8 NOT NULL,
  `mail_privacy` tinyint(8) NOT NULL DEFAULT '0',
  `privacy` tinyint(8) NOT NULL DEFAULT '0',
  `remember_token` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_active` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_User`),
  UNIQUE KEY `user` (`user`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=27 ;

--
-- Volcado de datos para la tabla `user`
--

INSERT INTO `user` (`id_User`, `user`, `name`, `name_privacy`, `mail`, `mail_privacy`, `privacy`, `remember_token`, `password`, `created_at`, `updated_at`, `is_active`) VALUES
(2, 'abelflkla', 'AbelF incias', 3, 'abel.fincias@gmail.com', 3, 3, NULL, '$2y$10$ikAfPo5MQv7ibJ7q1Zjf5u2mweSkgsVkSQ7vaqbi8hxs5G7bdbCdm', '2016-09-07 15:24:34', '2016-09-07 13:33:32', 1),
(3, 'olallez', 'Olalla Al', 2, 'olinoki@hotmail.com', 1, 0, NULL, '$2y$10$ikAfPo5MQv7ibJ7q1Zjf5u2mweSkgsVkSQ7vaqbi8hxs5G7bdbCdm', '2016-09-07 15:24:34', '2016-09-07 15:24:54', 1),
(4, 'rikigt', 'Ricardo Gil', 1, 'rixi69@gmail.com', 1, 2, NULL, '$2y$10$ikAfPo5MQv7ibJ7q1Zjf5u2mweSkgsVkSQ7vaqbi8hxs5G7bdbCdm', '2016-09-07 15:24:34', '2016-09-07 15:24:54', 1),
(5, 'peti', 'Alberto González', 3, 'betitoglez@hotmail.com', 1, 2, NULL, '$2y$10$ikAfPo5MQv7ibJ7q1Zjf5u2mweSkgsVkSQ7vaqbi8hxs5G7bdbCdm', '2016-09-07 15:24:34', '2016-09-07 15:24:54', 1),
(16, 'zamorano', 'Carlos Roncero', 2, 'carlosroncero@hotmail.com', 1, 0, NULL, '$2y$10$ikAfPo5MQv7ibJ7q1Zjf5u2mweSkgsVkSQ7vaqbi8hxs5G7bdbCdm', '2016-09-07 15:24:34', '2016-09-07 15:24:54', 1),
(26, 'betitoglez', 'Alberto', 0, 'betitoglez@gmail.com', 0, 0, 'BpRs6EgFOieZyjbQhDvs9VDWKrJ1QcBC48jGnW3mdY0cHcqmFjvGX64Wz6tR', '$2y$10$FyHgllv650P7IW9AJaT.OesiHtb6W1Ii0Cj/Th4RG/EnuDCtcdRve', '2016-09-08 12:19:10', '2016-09-08 13:03:14', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `userinfo`
--

DROP TABLE IF EXISTS `userinfo`;
CREATE TABLE IF NOT EXISTS `userinfo` (
  `id_User` int(32) NOT NULL,
  `id_Info` int(32) NOT NULL,
  `privacy` int(8) DEFAULT NULL,
  KEY `id_User` (`id_User`,`id_Info`),
  KEY `id_Info` (`id_Info`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `userinfo`
--

INSERT INTO `userinfo` (`id_User`, `id_Info`, `privacy`) VALUES
(2, 3, 1),
(2, 4, 2),
(3, 33, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=3 ;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Alberto', 'betitoglez@gmail.com', '$2y$10$4UW9yNrHxOe1uvi/zKopy.65CFeZVEmtUtGVhp/xx6mSQCF2GdZRu', NULL, '2016-09-07 10:20:34', '2016-09-07 10:20:34'),
(2, 'Juan', 'beti@ddd.es', '$2y$10$SZpOUmNfaU.K/TI0cQVubOAUUraOTlwr5T/4Z8XvO83xMotNbHNJO', NULL, '2016-09-07 13:32:12', '2016-09-07 13:32:12');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usertemp`
--

DROP TABLE IF EXISTS `usertemp`;
CREATE TABLE IF NOT EXISTS `usertemp` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `user` char(32) CHARACTER SET utf8 NOT NULL,
  `mail` varchar(128) CHARACTER SET utf8 NOT NULL,
  `phone` varchar(24) CHARACTER SET utf8 DEFAULT NULL,
  `name` varchar(32) CHARACTER SET utf8 NOT NULL,
  `sign_date` date NOT NULL,
  `key` char(128) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=6 ;

--
-- Volcado de datos para la tabla `usertemp`
--

INSERT INTO `usertemp` (`id`, `user`, `mail`, `phone`, `name`, `sign_date`, `key`) VALUES
(2, '', '', '', '', '2013-04-17', ''),
(3, '', '', '', '', '2013-04-20', ''),
(4, '', '', '', '', '2013-04-20', ''),
(5, 'pedro1', 'correo@es.com', '', '', '2013-04-21', 'Pass1!');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_his`
--

DROP TABLE IF EXISTS `user_his`;
CREATE TABLE IF NOT EXISTS `user_his` (
  `id_User` int(32) NOT NULL,
  `user` varchar(32) CHARACTER SET utf8 DEFAULT NULL,
  `name` varchar(32) CHARACTER SET utf8 DEFAULT NULL,
  `mail` varchar(64) CHARACTER SET utf8 DEFAULT NULL,
  KEY `user_his_id` (`id_User`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `user_his`
--

INSERT INTO `user_his` (`id_User`, `user`, `name`, `mail`) VALUES
(2, NULL, NULL, 'abel.fincias@gmail.com'),
(2, NULL, NULL, 'abel.fincias@tic.alten.es'),
(2, NULL, 'AbelF incias', NULL),
(2, NULL, 'nombre_raro', NULL),
(19, NULL, '', NULL),
(14, NULL, '', NULL),
(2, NULL, 'AbelF', NULL),
(2, NULL, '', '');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_contacts`
--
DROP VIEW IF EXISTS `vw_contacts`;
CREATE TABLE IF NOT EXISTS `vw_contacts` (
`contact` int(32)
,`id_User` int(32)
,`user` varchar(32)
,`name` varchar(32)
,`mail` varchar(64)
);
-- --------------------------------------------------------

--
-- Estructura para la vista `vw_contacts`
--
DROP TABLE IF EXISTS `vw_contacts`;

CREATE ALGORITHM=UNDEFINED DEFINER=`Jahiag_user`@`localhost` SQL SECURITY DEFINER VIEW `vw_contacts` AS (select distinct `contacts`.`id_User` AS `contact`,`contacts`.`id_Contact` AS `id_User`,if(`GetPrivacy`('p',`user`.`privacy`,`contacts`.`privacy`,`contacts`.`id_User`,`contacts`.`id_Contact`),`user`.`user`,'') AS `user`,if(((`contacts`.`name` is not null) and (`contacts`.`name` <> '')),`contacts`.`name`,if(`GetPrivacy`('pN',`user`.`name_privacy`,`contacts`.`name_privacy`,`contacts`.`id_User`,`contacts`.`id_Contact`),`user`.`name`,'')) AS `name`,if(((`contacts`.`mail` is not null) and (`contacts`.`mail` <> '')),`contacts`.`mail`,if(`GetPrivacy`('pM',`user`.`mail_privacy`,`contacts`.`mail_privacy`,`contacts`.`id_User`,`contacts`.`id_Contact`),`user`.`mail`,'')) AS `mail` from (`user` join `contacts` on((`user`.`id_User` = `contacts`.`id_Contact`))) order by if(((`contacts`.`name` is not null) and (`contacts`.`name` <> '')),`contacts`.`name`,if(`GetPrivacy`('pN',`user`.`name_privacy`,`contacts`.`name_privacy`,`contacts`.`id_User`,`contacts`.`id_Contact`),`user`.`name`,'')),if(`GetPrivacy`('p',`user`.`privacy`,`contacts`.`privacy`,`contacts`.`id_User`,`contacts`.`id_Contact`),`user`.`user`,''));

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `contacts`
--
ALTER TABLE `contacts`
  ADD CONSTRAINT `contacts_ibfk_1` FOREIGN KEY (`id_User`) REFERENCES `user` (`id_User`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `contactsgroup`
--
ALTER TABLE `contactsgroup`
  ADD CONSTRAINT `contactsgroup_ibfk_1` FOREIGN KEY (`id_Group`) REFERENCES `group` (`id_Group`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `contactsinfo`
--
ALTER TABLE `contactsinfo`
  ADD CONSTRAINT `contactsinfo_ibfk_2` FOREIGN KEY (`id_Info`) REFERENCES `info` (`id_Info`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `contactsinfo_ibfk_3` FOREIGN KEY (`id_User`) REFERENCES `user` (`id_User`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `contacts_his`
--
ALTER TABLE `contacts_his`
  ADD CONSTRAINT `contacts_his_ibfk_1` FOREIGN KEY (`id_User`) REFERENCES `user` (`id_User`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `friendrequest`
--
ALTER TABLE `friendrequest`
  ADD CONSTRAINT `friendrequest_ibfk_2` FOREIGN KEY (`id_Contact`) REFERENCES `user` (`id_User`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `friendrequest_ibfk_1` FOREIGN KEY (`id_User`) REFERENCES `user` (`id_User`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `group`
--
ALTER TABLE `group`
  ADD CONSTRAINT `id_User` FOREIGN KEY (`id_User`) REFERENCES `user` (`id_User`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `groupinfo`
--
ALTER TABLE `groupinfo`
  ADD CONSTRAINT `groupinfo_ibfk_1` FOREIGN KEY (`id_Info`) REFERENCES `info` (`id_Info`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `groupinfo_ibfk_2` FOREIGN KEY (`id_Group`) REFERENCES `group` (`id_Group`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `infocontact`
--
ALTER TABLE `infocontact`
  ADD CONSTRAINT `id_Contact` FOREIGN KEY (`id_Contact`) REFERENCES `user` (`id_User`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `id_Info` FOREIGN KEY (`id_Info`) REFERENCES `info` (`id_Info`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `userinfo`
--
ALTER TABLE `userinfo`
  ADD CONSTRAINT `userinfo_ibfk_1` FOREIGN KEY (`id_Info`) REFERENCES `info` (`id_Info`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `userinfo_ibfk_2` FOREIGN KEY (`id_User`) REFERENCES `user` (`id_User`) ON DELETE CASCADE ON UPDATE CASCADE;
SET FOREIGN_KEY_CHECKS=1;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
