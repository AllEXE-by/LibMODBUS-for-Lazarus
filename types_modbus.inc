
{╔═══════════════════════════════════════════════════════════════════════════════╗
 ║                       ╔═╗╔═╗╔═══╗╔═══╗╔══╗ ╔╗ ╔╗╔═══╗                         ║
 ║                       ║║╚╝║║║╔═╗║╚╗╔╗║║╔╗║ ║║ ║║║╔═╗║                         ║
 ║                       ║╔╗╔╗║║║ ║║ ║║║║║╚╝╚╗║║ ║║║╚══╗                         ║
 ║                       ║║║║║║║║ ║║ ║║║║║╔═╗║║║ ║║╚══╗║                         ║
 ║                       ║║║║║║║╚═╝║╔╝╚╝║║╚═╝║║╚═╝║║╚═╝║                         ║
 ║                       ╚╝╚╝╚╝╚═══╝╚═══╝╚═══╝╚═══╝╚═══╝                         ║
 ║                                                                               ║
 ║           ╔═══╗╔═══╗╔═══╗     ╔╗   ╔═══╗╔════╗╔═══╗╔═══╗╔╗ ╔╗╔═══╗            ║
 ║           ║╔══╝║╔═╗║║╔═╗║     ║║   ║╔═╗║╚══╗ ║║╔═╗║║╔═╗║║║ ║║║╔═╗║            ║
 ║           ║╚══╗║║ ║║║╚═╝║     ║║   ║║ ║║  ╔╝╔╝║║ ║║║╚═╝║║║ ║║║╚══╗            ║
 ║           ║╔══╝║║ ║║║╔╗╔╝     ║║ ╔╗║╚═╝║ ╔╝╔╝ ║╚═╝║║╔╗╔╝║║ ║║╚══╗║            ║
 ║           ║║   ║╚═╝║║║║╚╗     ║╚═╝║║╔═╗║╔╝ ╚═╗║╔═╗║║║║╚╗║╚═╝║║╚═╝║            ║
 ║           ╚╝   ╚═══╝╚╝╚═╝     ╚═══╝╚╝ ╚╝╚════╝╚╝ ╚╝╚╝╚═╝╚═══╝╚═══╝            ║
 ║                                                                               ║
 ║  Copyright (C)               2021, Alexei NUZHKOV, <alexeidg@tut.by>, et al.  ║
 ║  Авторское право (С)         2021, Алексей НУЖКОВ и другие.                   ║
 ║                                                                               ║
 ║  Данное программное обеспечение лицензировано так же, как Lib_MODBUS.         ║
 ║  Условия доступны по адресу: https://Lib_MODBUS.org/                          ║
 ║                                                                               ║
 ║  Вы можете использовать, копировать, изменять, объединять, публиковать,       ║
 ║  распространять и/или продавать копии программного обеспечения                ║
 ║  в соответствии с условиями: https://Lib_MODBUS.org/                          ║
 ║                                                                               ║
 ║  Это программное обеспечение распространяется на условиях "КАК ЕСТЬ",         ║
 ║  БЕЗ каких либо ГАРАНТИЙ, явных или подразумеваемых.                          ║
 ╚═══════════════════════════════════════════════════════════════════════════════╝} 

const
 {$IFDEF Linux}
 {$DEFINE extdecl:= cdecl}
 Lib_MODBUS = 'Lib_MODBUS.' + SharedSuffix + '.5'; { /usr/lib/x86_64-linux-gnu/Lib_MODBUS.so.5 }
 {$ENDIF}
 {$IFDEF Windows}
 {$DEFINE extdecl:= stdcall}
 Lib_MODBUS = 'modbus.' + SharedSuffix;
 {$ENDIF}

type

TMODBUS_RTU_IFACE                = (
  MODBUS_RTU_RS232               = 0,
  MODBUS_RTU_RS485               = 1
);

TMODBUS_RTU_RTS                  = (
  MODBUS_RTU_RTS_NONE            = 0,
  MODBUS_RTU_RTS_UP              = 1,
  MODBUS_RTU_RTS_DOWN            = 2
);

TMODBUS_ERROR_RECOVERY           = (
  MODBUS_ERROR_RECOVERY_NONE     = 0,
  MODBUS_ERROR_RECOVERY_LINK     = 1,
  MODBUS_ERROR_RECOVERY_PROTOCOL = 2
);

 p_modbus = ^t_modbus;

 _modbus = record
 slave                 : Integer;
 soket                 : Integer;
 debug                 : Integer;
 error_recovery        : Integer;
 response_timeout      : TimeVal;
 byte_timeout          : TimeVal;
 indication_timeout    : TimeVal;
 backend               : Pointer;
 backend_data          : Pointer;
 end;

 t_modbus = _modbus;

 _modbus_mapping = record
 nb_bits               : Integer;
 start_bits            : Integer;
 nb_input_bits         : Integer;
 start_input_bits      : Integer;
 nb_input_registers    : Integer;
 start_input_registers : Integer;
 nb_registers          : Integer;
 start_registers       : Integer;
 tab_bits              : pByte;
 tab_input_bits        : pByte;
 tab_input_registers   : pWord;
 tab_registers         : pWord;
 end;

 t_modbus_mapping = _modbus_mapping;
 p_modbus_mapping = ^t_modbus_mapping;

 t_set_rts = procedure(ctx : p_modbus; on_rts : Integer);
 p_set_rts = ^t_set_rts;

