unit ModBus;

{╔═══════════════════════════════════════════════════════════════════════════════╗
 ║                       ╔═╗╔═╗╔═══╗╔═══╗╔══╗ ╔╗ ╔╗╔═══╗                         ║
 ║                       ║ ╚╝ ║║╔═╗║╚╗╔╗║║╔╗║ ║║ ║║║╔═╗║                         ║
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

{$mode objfpc}{$H+}{$MACRO ON}

interface

uses
   DynLibs,
   {$IFDEF Windows}
   Winsock
   {$ENDIF}
   {$IFDEF Linux}

   {$ENDIF};

{$DEFINE NO_STATIC_LIBMODBUS}

{$i types_modbus.inc}

function  modbus_errno                             : Integer;
function  modbus_get_error_recovery(ctx : p_modbus): Integer;
function  modbus_get_debug         (ctx : p_modbus): Integer;

{$IFNDEF STATIC_LIBMODBUS}
function  InitializeModBus                         : Boolean;
procedure UnInitializeModBus                                ;
{$ENDIF}

 { TDefaultModBus }
 type
  {$IFDEF UNIX}
  EModBusError = class(Exception)
  public
    ErrorCode: integer;
    ErrorMessage: string;
  end;
  {$ENDIF}

  TModBusHandle  = t_modbus;
  PModBusHandle  = ^TModBusHandle;

  TModBusMapping = t_modbus_mapping;
  PModBusMapping = ^TModBusMapping;

  TDefaultModBus = class(TObject)
  private
    FHandle                            : PModBusHandle;
    FConnect                           : Boolean;   // Флаг приснак подключения
    FLastError                         : Integer;   // Ошибка последней операции
    FRaiseExcept                       : Boolean;   // Флаг разрешения исключения
    procedure      ExceptCheck;                                                                            virtual; // Обработчик исключений
    function       GetDebug: Boolean;                                                                      virtual;
    function       GetErrorDesc: String;                                                                   virtual; // Возвращает описание исключения
    function       GetErrorRecovery: Integer;                                                              virtual;
    function       GetHeaderLength: Integer;                                                               virtual;
    function       GetIndicationTimeout: Integer;                                                          virtual;
    function       GetSlave: Integer;                                                                      virtual;
    function       GetSocet: Integer;                                                                      virtual;
    function       GetBitTimeOut: Integer;                                                                 virtual;
    function       GetResponseTimeOut: Integer;                                                            virtual;
    procedure      SetDebug(AValue: Boolean);                                                              virtual;
    procedure      SetErrorRecovery(AValue: Integer);                                                      virtual;
    procedure      SetIndicationTimeOut(AValue: Integer);                                                  virtual;
    procedure      SetSlave(AValue: Integer);                                                              virtual;
    procedure      SetSocet(AValue: Integer);                                                              virtual;
    procedure      SetBitTimeOut(AValue: Integer);                                                         virtual;
    procedure      SetResponseTimeOut(AValue: Integer);                                                    virtual;
  public
    constructor    Create;
    destructor     Destroy;                                                                                override;
    procedure      Disconnect;                                                                             virtual; // Закрыть соединение
    function       Connect             : Boolean;                                                          virtual; // Устанавливаем соединение
    function       Flush               : Boolean;                                                          virtual; // Очистка очереди приема/передачи
    function       GetErrorDest        : String;                                                           virtual;
    function       ReadBits             (const AAddress, ACount : Integer; var   Buffer): Integer;         virtual; // Прочитать несколько бит функция 0х01
    function       ReadInputBits        (const AAddress, ACount : Integer; var   Buffer): Integer;         virtual; // Прочитать несколько входных бит функция 0х02
    function       ReadRegisters        (const AAddress, ACount : Integer; var   Buffer): Integer;         virtual;
    function       ReadInputRegisters   (const AAddress, ACount : Integer; var   Buffer): Integer;         virtual;
    function       WriteBits            (const AAddress, ACount : Integer; var   Buffer): Integer;         virtual;
    function       WriteRegisters       (const AAddress, ACount : Integer; var   Buffer): Integer;         virtual;
    function       WriteBit             (const AAddress : Integer; const Buffer): Integer;                 virtual;
    function       WriteRegister        (const AAddress : Integer; const Buffer): Integer;                 virtual;
    function       MaskWriteRegicter    (const AAddress : Integer; const AndMask, OrMask : Word): Integer; virtual;
    function       WriteAndReadRegisters(const AWriteAddr, AWriteCnt : Integer;const Write_Buffer;
                                         const AReadAddr , AReadCnt  : Integer;var   Read_Buffer): Integer;virtual;
    function       ReportSlaveId        (const ACount   : Integer; var Buffer): Integer;                     virtual;
    function       SendRawRequest       (const Buffer; const ALength : Integer): Integer;                  virtual;
  published
    property       Connected           : Boolean read FConnect;                                             // Флаг признак соединения
    property       HeaderLength        : Integer read GetHeaderLength;                                      // Длина заголовка
    property       RaiseExcept         : Boolean read FRaiseExcept         write FRaiseExcept;              // Реакция на исключения
    property       Slave               : Integer read GetSlave             write SetSlave;                  // Идентификатор Slave устройства
    property       Socet               : Integer read GetSocet             write SetSocet;                  // Сокет
    property       ResponseTimeOut     : Integer read GetResponseTimeOut   write SetResponseTimeOut;        // Таймаут сообщения
    property       BitTimeOut          : Integer read GetBitTimeout        write SetBitTimeout;             // Таймаут бита
    property       IndicationTimeOut   : Integer read GetIndicationTimeout write SetIndicationTimeOut;      // Таймаут индикации
    property       ErrorRecovery       : Integer read GetErrorRecovery     write SetErrorRecovery;          // Режим восстановления после ошибки
    property       Debug               : Boolean read GetDebug             write SetDebug;                  // Режим отладки
  end;

  TModBus = TDefaultModBus;

  { TModBusRtu }

  TModBusRTU = class(TDefaultModBus)
  private
    FDevice                            : String;
    FBaudRate                          : Integer;
    FDataBits                          : Integer;
    FParity                            : Char;
    FStopBit                           : Integer;
    function       GetRts              : Integer;                   virtual;
    function       GetRtsDelay         : Integer;                   virtual;
    function       GetSerialMode       : Integer;                   virtual;
    procedure      SetBaudrate           (AValue: Integer);         virtual;
    procedure      SetDataBits           (AValue: Integer);         virtual;
    procedure      SetDevice             (const AValue: String);    virtual;
    procedure      SetParity             (AValue: Char);            virtual;
    procedure      SetRts                (AValue: Integer);         virtual;
    procedure      SetRtsDelay           (AValue: Integer);         virtual;
    procedure      SetSerialMode         (AValue: Integer);         virtual;
    procedure      SetStopBit            (AValue: Integer);         virtual;
  public
    constructor    Create;
    destructor     Destroy;                                         override;
    procedure      ReSettings;                                      virtual; {RTU}
  published
    property       Device              : String  read FDevice       write SetDevice; {RTU}
    property       BaudRate            : Integer read FBaudrate     write SetBaudrate; {RTU}
    property       Parity              : Char    read FParity       write SetParity; {RTU}
    property       DataBits            : Integer read FDataBits     write SetDataBits; {RTU}
    property       StopBit             : Integer read FStopBit      write SetStopBit; {RTU}
    property       SerialMode          : Integer read GetSerialMode write SetSerialMode; {RTU}
    property       Rts                 : Integer read GetRts        write SetRts;
    property       RtsDelay            : Integer read GetRtsDelay   write SetRtsDelay;
  end;

  PModBusRTU = ^TModBusRTU;

  { TModBusTCP }

  TModBusTCP = class(TDefaultModBus)
  private
     FIPAddress                        : String;
     FPort                             : Integer;
     procedure     SetIPAddress          (AValue: String);          virtual;
     procedure     SetPort               (AValue: Integer);         virtual;
  public
    constructor    Create;
    destructor     Destroy;                                         override;
    procedure      ReSettings;                                      virtual;
  published
    property       IPAddress           : String  read FIPAddress    write SetIPAddress;
    property       Port                : Integer read FPort         write SetPort;
  end;

  PModBusTCP = ^TModBusTCP;

  { TModBusTCP_IP }

  TModBusTCP_IP = class(TDefaultModBus)
  private
     FIPAddress                        : String;
     FService                          : String;
     procedure     SetIPAddress          (AValue: String);          virtual;
     procedure     SetService            (AValue: String);          virtual;
  public
    constructor    Create;
    destructor     Destroy;                                         override;
    procedure      ReSettings;                                      virtual;
  published
    property       IPAddress           : String read FIPAddress     write SetIPAddress;
    property       Service             : String read FService       write SetService;
  end;

  PModBusTCP_IP = ^TModBusTCP_IP;

{$IFDEF STATIC_LIBMODBUS}
procedure modbus_close                    (ctx : p_modbus); extdecl; external Lib_MODBUS;
function  modbus_connect                  (ctx : p_modbus) : Integer; extdecl; external Lib_MODBUS;
function  modbus_flush                    (ctx : p_modbus) : Integer; extdecl; external Lib_MODBUS;
procedure modbus_free                     (ctx : p_modbus); extdecl; external Lib_MODBUS;
function  modbus_get_byte_from_bits       (const src : pByte; idx : Integer; nb_bits : LongWord) : Byte; extdecl; external Lib_MODBUS;
function  modbus_get_byte_timeout         (ctx : p_modbus; to_sec : pWord; to_usec : pWord) : Integer; extdecl; external Lib_MODBUS;
function  modbus_get_float                (const src : pWord) : Single; extdecl; external Lib_MODBUS;
function  modbus_get_float_abcd           (const src : pWord) : Single; extdecl; external Lib_MODBUS;
function  modbus_get_float_badc           (const src : pWord) : Single; extdecl; external Lib_MODBUS;
function  modbus_get_float_cdab           (const src : pWord) : Single; extdecl; external Lib_MODBUS;
function  modbus_get_float_dcba           (const src : pWord) : Single; extdecl; external Lib_MODBUS;
function  modbus_get_header_length        (ctx : p_modbus) : Integer; extdecl; external Lib_MODBUS;
function  modbus_get_indication_timeout   (ctx : p_modbus; to_sec : pWord; to_usec : pWord) : Integer; extdecl; external Lib_MODBUS;
function  modbus_get_response_timeout     (ctx : p_modbus; to_sec : pWord; to_usec : pWord) : Integer; extdecl; external Lib_MODBUS;
function  modbus_get_slave                (ctx : p_modbus) : Integer; extdecl; external Lib_MODBUS;
function  modbus_get_socket               (ctx : p_modbus) : Integer; extdecl; external Lib_MODBUS;
procedure modbus_mapping_free             (mb_mapping : p_modbus_mapping); extdecl; external Lib_MODBUS;
function  modbus_mapping_new              (nb_bits : Integer; nb_input_bits : Integer; nb_registers : Integer; nb_input_registers : Integer) : p_modbus_mapping; extdecl; external Lib_MODBUS;
function  modbus_mapping_new_start_address(start_bits : LongWord; nb_bits : LongWord;
                                           start_input_bits : LongWord; nb_input_bits : LongWord;
                                           start_registers : LongWord; nb_registers : LongWord;
                                           start_input_registers : LongWord;
                                           nb_input_registers : LongWord): p_modbus_mapping; extdecl; external Lib_MODBUS;
function  modbus_mask_write_register      (ctx : p_modbus; addr : Integer; and_mask : Word; or_mask : Word) : Integer; extdecl; external Lib_MODBUS;
function  modbus_new_rtu                  (const device : pChar; baud: Integer; parity: Char; data_bit : Integer; stop_bit : Integer) : p_modbus; extdecl; external Lib_MODBUS;
function  modbus_new_tcp                  (const ip_address : pChar; port : Integer) : p_modbus; extdecl; external Lib_MODBUS;
function  modbus_new_tcp_pi               (const node : pChar; const service : pChar) : p_modbus; extdecl; external Lib_MODBUS;
function  modbus_read_bits                (ctx : p_modbus; addr : Integer; nb : Integer; dest : pByte) : Integer; extdecl; external Lib_MODBUS;
function  modbus_read_input_bits          (ctx : p_modbus; addr : Integer; nb : Integer; dest : pByte) : Integer; extdecl; external Lib_MODBUS;
function  modbus_read_registers           (ctx : p_modbus; addr : Integer; nb : Integer; dest : pWord) : Integer; extdecl; external Lib_MODBUS;
function  modbus_read_input_registers     (ctx : p_modbus; addr : Integer; nb : Integer; dest : pWord) : Integer; extdecl; external Lib_MODBUS;
function  modbus_receive                  (ctx : p_modbus; req : pByte) : Integer; extdecl; external Lib_MODBUS;
function  modbus_receive_confirmation     (ctx : p_modbus; rsp : pByte) : Integer; extdecl; external Lib_MODBUS;
function  modbus_reply                    (ctx : p_modbus; const req : pByte; req_length : Integer; mb_mapping : p_modbus_mapping) : Integer; extdecl; external Lib_MODBUS;
function  modbus_reply_exception          (ctx : p_modbus; const req : pByte; exception_code : LongWord) : Integer; extdecl; external Lib_MODBUS;
function  modbus_report_slave_id          (ctx : p_modbus; max_dest : Integer; dest : pByte) : Integer; extdecl; external Lib_MODBUS;
function  modbus_rtu_get_rts              (ctx : p_modbus) : Integer; extdecl; external Lib_MODBUS;
function  modbus_rtu_get_rts_delay        (ctx : p_modbus) : Integer; extdecl; external Lib_MODBUS;
function  modbus_rtu_get_serial_mode      (ctx : p_modbus) : Integer; extdecl; external Lib_MODBUS;
function  modbus_rtu_set_custom_rts       (ctx : p_modbus; set_rts : p_set_rts) : Integer; extdecl; external Lib_MODBUS;
function  modbus_rtu_set_rts              (ctx : p_modbus; mode: Integer) : Integer; extdecl; external Lib_MODBUS;
function  modbus_rtu_set_rts_delay        (ctx : p_modbus; usec : Integer) : Integer; extdecl; external Lib_MODBUS;
function  modbus_rtu_set_serial_mode      (ctx : p_modbus; mode: Integer) : Integer; extdecl; external Lib_MODBUS;
function  modbus_send_raw_request         (ctx : p_modbus; raw_req : pByte; raw_req_length : Integer) : Integer; extdecl; external Lib_MODBUS;
procedure modbus_set_bits_from_byte       (dest : pByte; idx : Integer; const value : Byte); extdecl; external Lib_MODBUS;
procedure modbus_set_bits_from_bytes      (dest : pByte; idx : Integer; nb_bits : LongWord; const tab_byte : pByte); extdecl; external Lib_MODBUS;
function  modbus_set_byte_timeout         (ctx : p_modbus; to_sec : LongWord; to_usec : LongWord) : Integer; extdecl; external Lib_MODBUS;
function  modbus_set_debug                (ctx : p_modbus; flag : Integer) : Integer; extdecl; external Lib_MODBUS;
function  modbus_set_error_recovery       (ctx : p_modbus; error_recovery : Integer) : Integer; extdecl; external Lib_MODBUS;
procedure modbus_set_float                (f : Single; dest : pWord); extdecl; external Lib_MODBUS;
procedure modbus_set_float_abcd           (f : Single; dest : pWord); extdecl; external Lib_MODBUS;
procedure modbus_set_float_badc           (f : Single; dest : pWord); extdecl; external Lib_MODBUS;
procedure modbus_set_float_cdab           (f : Single; dest : pWord); extdecl; external Lib_MODBUS;
procedure modbus_set_float_dcba           (f : Single; dest : pWord); extdecl; external Lib_MODBUS;
function  modbus_set_indication_timeout   (ctx : p_modbus; to_sec : LongWord; to_usec : LongWord) : Integer; extdecl; external Lib_MODBUS;
function  modbus_set_response_timeout     (ctx : p_modbus; to_sec : LongWord; to_usec : LongWord) : Integer; extdecl; external Lib_MODBUS;
function  modbus_set_slave                (ctx : p_modbus; slave : Integer) : Integer; extdecl; external Lib_MODBUS;
function  modbus_set_socket               (ctx : p_modbus; s : Integer) : Integer; extdecl; external Lib_MODBUS;
function  modbus_strerror                 (errnum : Integer) : pChar; extdecl; external Lib_MODBUS;
function  modbus_tcp_accept               (ctx : p_modbus; s : pInteger) : Integer; extdecl; external Lib_MODBUS;
function  modbus_tcp_listen               (ctx : p_modbus; nb_connection : Integer) : Integer; extdecl; external Lib_MODBUS;
function  modbus_tcp_pi_accept            (ctx : p_modbus; s : pInteger) : Integer; extdecl; external Lib_MODBUS;
function  modbus_tcp_pi_listen            (ctx : p_modbus; nb_connection : Integer) : Integer; extdecl; external Lib_MODBUS;
function  modbus_write_and_read_registers (ctx : p_modbus; write_addr : Integer; write_nb : Integer; const src : pWord;
                                           read_addr : Integer; read_nb : Integer; dest : pWord) : Integer; extdecl; external Lib_MODBUS;
function  modbus_write_bit                (ctx : p_modbus; addr : Integer; status : Integer) : Integer; extdecl; external Lib_MODBUS;
function  modbus_write_bits               (ctx : p_modbus; addr : Integer; nb : Integer; const data : pByte) : Integer; extdecl; external Lib_MODBUS;
function  modbus_write_register           (ctx : p_modbus; addr : Integer; const value : Word) : Integer; extdecl; external Lib_MODBUS;
function  modbus_write_registers          (ctx : p_modbus; addr : Integer; nb : Integer; const data : pWord) : Integer; extdecl; external Lib_MODBUS;
{$ELSE}

var
  LibHandle : TLibHandle;
  modbus_close                     : procedure(ctx : p_modbus); extdecl;
  modbus_connect                   : function (ctx : p_modbus) : Integer; extdecl;
  modbus_flush                     : function (ctx : p_modbus) : Integer; extdecl;
  modbus_free                      : procedure(ctx : p_modbus); extdecl;
  modbus_get_byte_from_bits        : function (const src : pByte; idx : Integer; nb_bits : LongWord) : Byte; extdecl;
  modbus_get_byte_timeout          : function (ctx : p_modbus; to_sec : pWord; to_usec : pWord) : Integer; extdecl;
  modbus_get_float                 : function (const src : pWord) : Single; extdecl;
  modbus_get_float_abcd            : function (const src : pWord) : Single; extdecl;
  modbus_get_float_badc            : function (const src : pWord) : Single; extdecl;
  modbus_get_float_cdab            : function (const src : pWord) : Single; extdecl;
  modbus_get_float_dcba            : function (const src : pWord) : Single; extdecl;
  modbus_get_header_length         : function (ctx : p_modbus) : Integer; extdecl;
  modbus_get_indication_timeout    : function (ctx : p_modbus; to_sec : pWord; to_usec : pWord) : Integer; extdecl;
  modbus_get_response_timeout      : function (ctx : p_modbus; to_sec : pWord; to_usec : pWord) : Integer; extdecl;
  modbus_get_slave                 : function (ctx : p_modbus) : Integer; extdecl;
  modbus_get_socket                : function (ctx : p_modbus) : Integer; extdecl;
  modbus_mapping_free              : procedure(mb_mapping : p_modbus_mapping); extdecl;
  modbus_mapping_new               : function (nb_bits : Integer; nb_input_bits : Integer; nb_registers : Integer; nb_input_registers : Integer) : p_modbus_mapping; extdecl;
  modbus_mapping_new_start_address : function (start_bits : LongWord; nb_bits : LongWord;
                                               start_input_bits : LongWord; nb_input_bits : LongWord;
                                               start_registers : LongWord; nb_registers : LongWord;
                                               start_input_registers : LongWord; nb_input_registers : LongWord): p_modbus_mapping; extdecl;
  modbus_mask_write_register       : function (ctx : p_modbus; addr : Integer; and_mask : Word; or_mask : Word) : Integer; extdecl;
  modbus_new_rtu                   : function (const device : pChar; baud: Integer; parity: Char; data_bit : Integer; stop_bit : Integer) : p_modbus; extdecl;
  modbus_new_tcp                   : function (const ip_address : pChar; port : Integer) : p_modbus; extdecl;
  modbus_new_tcp_pi                : function (const node : pChar; const service : pChar) : p_modbus; extdecl;
  modbus_read_bits                 : function (ctx : p_modbus; addr : Integer; nb : Integer; dest : pByte) : Integer; extdecl;
  modbus_read_input_bits           : function (ctx : p_modbus; addr : Integer; nb : Integer; dest : pByte) : Integer; extdecl;
  modbus_read_registers            : function (ctx : p_modbus; addr : Integer; nb : Integer; dest : pWord) : Integer; extdecl;
  modbus_read_input_registers      : function (ctx : p_modbus; addr : Integer; nb : Integer; dest : pWord) : Integer; extdecl;
  modbus_receive                   : function (ctx : p_modbus; req : pByte) : Integer; extdecl;
  modbus_receive_confirmation      : function (ctx : p_modbus; rsp : pByte) : Integer; extdecl;
  modbus_reply                     : function (ctx : p_modbus; const req : pByte; req_length : Integer; mb_mapping : p_modbus_mapping) : Integer; extdecl;
  modbus_reply_exception           : function (ctx : p_modbus; const req : pByte; exception_code : LongWord) : Integer; extdecl;
  modbus_report_slave_id           : function (ctx : p_modbus; max_dest : Integer; dest : pByte) : Integer; extdecl;
  modbus_rtu_get_rts               : function (ctx : p_modbus) : Integer; extdecl;
  modbus_rtu_get_rts_delay         : function (ctx : p_modbus) : Integer; extdecl;
  modbus_rtu_get_serial_mode       : function (ctx : p_modbus) : Integer; extdecl;
  modbus_rtu_set_custom_rts        : function (ctx : p_modbus; set_rts : p_set_rts) : Integer; extdecl;
  modbus_rtu_set_rts               : function (ctx : p_modbus; mode: Integer) : Integer; extdecl;
  modbus_rtu_set_rts_delay         : function (ctx : p_modbus; usec : Integer) : Integer; extdecl;
  modbus_rtu_set_serial_mode       : function (ctx : p_modbus; mode: Integer) : Integer; extdecl;
  modbus_send_raw_request          : function (ctx : p_modbus; raw_req : pByte; raw_req_length : Integer) : Integer; extdecl;
  modbus_set_bits_from_byte        : procedure(dest : pByte; idx : Integer; const value : Byte); extdecl;
  modbus_set_bits_from_bytes       : procedure(dest : pByte; idx : Integer; nb_bits : LongWord; const tab_byte : pByte); extdecl;
  modbus_set_byte_timeout          : function (ctx : p_modbus; to_sec : LongWord; to_usec : LongWord) : Integer; extdecl;
  modbus_set_debug                 : function (ctx : p_modbus; flag : Integer) : Integer; extdecl;
  modbus_set_error_recovery        : function (ctx : p_modbus; error_recovery : Integer) : Integer; extdecl;
  modbus_set_float                 : procedure(f : Single; dest : pWord); extdecl;
  modbus_set_float_abcd            : procedure(f : Single; dest : pWord); extdecl;
  modbus_set_float_badc            : procedure(f : Single; dest : pWord); extdecl;
  modbus_set_float_cdab            : procedure(f : Single; dest : pWord); extdecl;
  modbus_set_float_dcba            : procedure(f : Single; dest : pWord); extdecl;
  modbus_set_indication_timeout    : function (ctx : p_modbus; to_sec : LongWord; to_usec : LongWord) : Integer; extdecl;
  modbus_set_response_timeout      : function (ctx : p_modbus; to_sec : LongWord; to_usec : LongWord) : Integer; extdecl;
  modbus_set_slave                 : function (ctx : p_modbus; slave : Integer) : Integer; extdecl;
  modbus_set_socket                : function (ctx : p_modbus; s : Integer) : Integer; extdecl;
  modbus_strerror                  : function (errnum : Integer) : pChar; extdecl;
  modbus_tcp_accept                : function (ctx : p_modbus; s : pInteger) : Integer; extdecl;
  modbus_tcp_listen                : function (ctx : p_modbus; nb_connection : Integer) : Integer; extdecl;
  modbus_tcp_pi_accept             : function (ctx : p_modbus; s : pInteger) : Integer; extdecl;
  modbus_tcp_pi_listen             : function (ctx : p_modbus; nb_connection : Integer) : Integer; extdecl;
  modbus_write_and_read_registers  : function (ctx : p_modbus; write_addr : Integer; write_nb : Integer; const src : pWord;
                                               read_addr : Integer; read_nb : Integer; dest : pWord) : Integer; extdecl;
  modbus_write_bit                 : function (ctx : p_modbus; addr : Integer; status : Integer) : Integer; extdecl;
  modbus_write_bits                : function (ctx : p_modbus; addr : Integer; nb : Integer; const data : pByte) : Integer; extdecl;
  modbus_write_register            : function (ctx : p_modbus; addr : Integer; const value : Word) : Integer; extdecl;
  modbus_write_registers           : function (ctx : p_modbus; addr : Integer; nb : Integer; const data : pWord) : Integer; extdecl;
{$ENDIF}

implementation

{$IFNDEF STATIC_LIBMODBUS}
function InitializeModBus: boolean;
begin
  Result := false;
  LibHandle := LoadLibrary(Lib_MODBUS);
  if (LibHandle > NilHandle) then
  begin
    Pointer(modbus_close)                    := GetProcedureAddress(LibHandle,'modbus_close');
    Pointer(modbus_connect)                  := GetProcedureAddress(LibHandle,'modbus_connect');
    Pointer(modbus_flush)                    := GetProcedureAddress(LibHandle,'modbus_flush');
    Pointer(modbus_free)                     := GetProcedureAddress(LibHandle,'modbus_free');
    Pointer(modbus_get_byte_from_bits)       := GetProcedureAddress(LibHandle,'modbus_get_byte_from_bits');
    Pointer(modbus_get_byte_timeout)         := GetProcedureAddress(LibHandle,'modbus_get_byte_timeout');
    Pointer(modbus_get_float)                := GetProcedureAddress(LibHandle,'modbus_get_float');
    Pointer(modbus_get_float_abcd)           := GetProcedureAddress(LibHandle,'modbus_get_float_abcd');
    Pointer(modbus_get_float_badc)           := GetProcedureAddress(LibHandle,'modbus_get_float_badc');
    Pointer(modbus_get_float_cdab)           := GetProcedureAddress(LibHandle,'modbus_get_float_cdab');
    Pointer(modbus_get_float_dcba)           := GetProcedureAddress(LibHandle,'modbus_get_float_dcba');
    Pointer(modbus_get_header_length)        := GetProcedureAddress(LibHandle,'modbus_get_header_length');
    Pointer(modbus_get_indication_timeout)   := GetProcedureAddress(LibHandle,'modbus_get_indication_timeout');
    Pointer(modbus_get_response_timeout)     := GetProcedureAddress(LibHandle,'modbus_get_response_timeout');
    Pointer(modbus_get_slave)                := GetProcedureAddress(LibHandle,'modbus_get_slave');
    Pointer(modbus_get_socket)               := GetProcedureAddress(LibHandle,'modbus_get_socket');
    Pointer(modbus_mapping_free)             := GetProcedureAddress(LibHandle,'modbus_mapping_free');
    Pointer(modbus_mapping_new)              := GetProcedureAddress(LibHandle,'modbus_mapping_new');
    Pointer(modbus_mapping_new_start_address):= GetProcedureAddress(LibHandle,'modbus_mapping_new_start_address');
    Pointer(modbus_mask_write_register)      := GetProcedureAddress(LibHandle,'modbus_mask_write_register');
    Pointer(modbus_new_rtu)                  := GetProcedureAddress(LibHandle,'modbus_new_rtu');
    Pointer(modbus_new_tcp)                  := GetProcedureAddress(LibHandle,'modbus_new_tcp');
    Pointer(modbus_new_tcp_pi)               := GetProcedureAddress(LibHandle,'modbus_new_tcp_pi');
    Pointer(modbus_read_bits)                := GetProcedureAddress(LibHandle,'modbus_read_bits');
    Pointer(modbus_read_input_bits)          := GetProcedureAddress(LibHandle,'modbus_read_input_bits');
    Pointer(modbus_read_input_registers)     := GetProcedureAddress(LibHandle,'modbus_read_input_registers');
    Pointer(modbus_read_registers)           := GetProcedureAddress(LibHandle,'modbus_read_registers');
    Pointer(modbus_receive)                  := GetProcedureAddress(LibHandle,'modbus_receive');
    Pointer(modbus_receive_confirmation)     := GetProcedureAddress(LibHandle,'modbus_receive_confirmation');
    Pointer(modbus_reply)                    := GetProcedureAddress(LibHandle,'modbus_reply');
    Pointer(modbus_reply_exception)          := GetProcedureAddress(LibHandle,'modbus_reply_exception');
    Pointer(modbus_report_slave_id)          := GetProcedureAddress(LibHandle,'modbus_report_slave_id');
    Pointer(modbus_rtu_get_rts)              := GetProcedureAddress(LibHandle,'modbus_rtu_get_rts');
    Pointer(modbus_rtu_get_rts_delay)        := GetProcedureAddress(LibHandle,'modbus_rtu_get_rts_delay');
    Pointer(modbus_rtu_get_serial_mode)      := GetProcedureAddress(LibHandle,'modbus_rtu_get_serial_mode');
    Pointer(modbus_rtu_set_custom_rts)       := GetProcedureAddress(LibHandle,'modbus_rtu_set_custom_rts');
    Pointer(modbus_rtu_set_rts)              := GetProcedureAddress(LibHandle,'modbus_rtu_set_rts');
    Pointer(modbus_rtu_set_rts_delay)        := GetProcedureAddress(LibHandle,'modbus_rtu_set_rts_delay');
    Pointer(modbus_rtu_set_serial_mode)      := GetProcedureAddress(LibHandle,'modbus_rtu_set_serial_mode');
    Pointer(modbus_send_raw_request)         := GetProcedureAddress(LibHandle,'modbus_send_raw_request');
    Pointer(modbus_set_bits_from_byte)       := GetProcedureAddress(LibHandle,'modbus_set_bits_from_byte');
    Pointer(modbus_set_bits_from_bytes)      := GetProcedureAddress(LibHandle,'modbus_set_bits_from_bytes');
    Pointer(modbus_set_byte_timeout)         := GetProcedureAddress(LibHandle,'modbus_set_byte_timeout');
    Pointer(modbus_set_debug)                := GetProcedureAddress(LibHandle,'modbus_set_debug');
    Pointer(modbus_set_error_recovery)       := GetProcedureAddress(LibHandle,'modbus_set_error_recovery');
    Pointer(modbus_set_float)                := GetProcedureAddress(LibHandle,'modbus_set_float');
    Pointer(modbus_set_float_abcd)           := GetProcedureAddress(LibHandle,'modbus_set_float_abcd');
    Pointer(modbus_set_float_badc)           := GetProcedureAddress(LibHandle,'modbus_set_float_badc');
    Pointer(modbus_set_float_cdab)           := GetProcedureAddress(LibHandle,'modbus_set_float_cdab');
    Pointer(modbus_set_float_dcba)           := GetProcedureAddress(LibHandle,'modbus_set_float_dcba');
    Pointer(modbus_set_indication_timeout)   := GetProcedureAddress(LibHandle,'modbus_set_indication_timeout');
    Pointer(modbus_set_response_timeout)     := GetProcedureAddress(LibHandle,'modbus_set_response_timeout');
    Pointer(modbus_set_slave)                := GetProcedureAddress(LibHandle,'modbus_set_slave');
    Pointer(modbus_set_socket)               := GetProcedureAddress(LibHandle,'modbus_set_socket');
    Pointer(modbus_strerror)                 := GetProcedureAddress(LibHandle,'modbus_strerror');
    Pointer(modbus_tcp_accept)               := GetProcedureAddress(LibHandle,'modbus_tcp_accept');
    Pointer(modbus_tcp_listen)               := GetProcedureAddress(LibHandle,'modbus_tcp_listen');
    Pointer(modbus_tcp_pi_accept)            := GetProcedureAddress(LibHandle,'modbus_tcp_pi_accept');
    Pointer(modbus_tcp_pi_listen)            := GetProcedureAddress(LibHandle,'modbus_tcp_pi_listen');
    Pointer(modbus_write_and_read_registers) := GetProcedureAddress(LibHandle,'modbus_write_and_read_registers');
    Pointer(modbus_write_bit)                := GetProcedureAddress(LibHandle,'modbus_write_bit');
    Pointer(modbus_write_bits)               := GetProcedureAddress(LibHandle,'modbus_write_bits');
    Pointer(modbus_write_register)           := GetProcedureAddress(LibHandle,'modbus_write_register');
    Pointer(modbus_write_registers)          := GetProcedureAddress(LibHandle,'modbus_write_registers');
    {$IFDEF DEBUG}
    Writeln('Open the library ', ModBusLib);
    {$ENDIF}
    Result:=true;
  end
 else
  begin
    {$IFDEF DEBUG}
    Writeln('ERROR! Unable to open the library ', ModBusLib);
    {$ENDIF}
    Result := false;
  end;
end;

procedure UnInitializeModBus;
begin
  if (LibHandle > NilHandle) then FreeLibrary(LibHandle);
  {$IFDEF DEBUG}
  Writeln('Close the library ', ModBusLib);
  {$ENDIF}
end;
{$ENDIF}

function modbus_errno: Integer;
begin
 Result:= 0; //errno;
end;


function modbus_get_error_recovery(ctx: p_modbus): Integer;
begin
  if (ctx = nil) then
  begin
    //cerrno:= ESysEINVAL;
    Result:= -1;
  end;
  Result:= ctx^.error_recovery;
end;

function modbus_get_debug(ctx: p_modbus): Integer;
begin
  if (ctx = nil) then
  begin
    //cerrno:= ESysEINVAL;
    Result:= -1;
  end;
  Result:= ctx^.debug;
end;

{ TModBusTCP_IP }

procedure TModBusTCP_IP.SetIPAddress(AValue: String);
begin
  if FIPAddress = AValue then Exit;
  FIPAddress   := AValue;
  ReSettings;
end;

procedure TModBusTCP_IP.SetService(AValue: String);
begin
  if FService = AValue then Exit;
  FService   := AValue;
  ReSettings;
end;

constructor TModBusTCP_IP.Create;
begin
  inherited Create;
    FIPAddress:= '127.0.0.1';
    FService  := '1502';
    {$IFDEF DEBUG}
    Writeln('Create ModBus TCP IP Master device');
    {$ENDIF}
    ReSettings;
end;

destructor TModBusTCP_IP.Destroy;
begin
    modbus_free(FHandle);
  inherited Destroy;
end;

procedure TModBusTCP_IP.ReSettings;
begin
  if Assigned(FHandle) then modbus_free(FHandle);
  FHandle:=  modbus_new_tcp_pi(Pointer(FIPAddress), Pointer(FService));
  {$IFDEF DEBUG}
  if Assigned(FHandle) then Self.Debug:= true;
  {$ENDIF}
  if Assigned(FHandle) then FLastError:= 0 else FLastError:= -1;
  ExceptCheck;
end;

{ TModBusTCP }

procedure TModBusTCP.SetIPAddress(AValue: String);
begin
  if FIPAddress = AValue then Exit;
  FIPAddress:= AValue;
  ReSettings;
end;

procedure TModBusTCP.SetPort(AValue: Integer);
begin
  if FPort = AValue then Exit;
  FPort:= AValue;
  ReSettings;
end;

constructor TModBusTCP.Create;
begin
  inherited Create;
    FIPAddress:= '127.0.0.1';
    FPort:=  1502;
    {$IFDEF DEBUG}
    Writeln('Create ModBus TCP Master device');
    {$ENDIF}
    ReSettings;
end;

destructor TModBusTCP.Destroy;
begin
    modbus_free(FHandle);
  inherited Destroy;
end;

procedure TModBusTCP.ReSettings;
begin
  if Assigned(FHandle) then modbus_free(FHandle);
  FHandle:=  modbus_new_tcp(Pointer(FIPAddress), FPort);
  {$IFDEF DEBUG}
  if Assigned(FHandle) then Self.Debug:= true;
  {$ENDIF}
  if Assigned(FHandle) then FLastError:= 0 else FLastError:= -1;
  ExceptCheck;
end;

{ TModBusRtu }

procedure   TModBusRtu.SetDevice(const AValue: String);
begin
  FDevice:= AValue;
  ReSettings;
end;

procedure   TModBusRtu.SetBaudrate(AValue: Integer);
begin
  if FBaudRate = AValue then Exit;
  FBaudRate:= AValue;
  ReSettings;
end;

procedure   TModBusRtu.SetParity(AValue: Char);
begin
  if FParity = AValue then Exit;
  FParity:= AValue;
  ReSettings;
end;

procedure   TModBusRtu.SetDataBits(AValue: Integer);
begin
  if FDataBits = AValue then Exit;
  FDataBits:= AValue;
  ReSettings;
end;

procedure   TModBusRtu.SetStopBit(AValue: Integer);
begin
  if FStopBit = AValue then Exit;
  FStopBit:= AValue;
  ReSettings;
end;

procedure   TModBusRtu.SetSerialMode(AValue: Integer);
begin
  FLastError:= modbus_rtu_set_serial_mode(fHandle, AValue);
  ExceptCheck;
end;

function    TModBusRtu.GetSerialMode: Integer;
begin
  Result:= modbus_rtu_get_serial_mode(FHandle);
  ExceptCheck;
end;

procedure   TModBusRtu.SetRts(AValue: Integer);
begin
  FLastError:= modbus_rtu_set_rts(fHandle, AValue);
  ExceptCheck;
end;

function    TModBusRtu.GetRts: Integer;
begin
  Result:= modbus_rtu_get_rts(fHandle);
  ExceptCheck;
end;

procedure   TModBusRtu.SetRtsDelay(AValue: Integer);
begin
  FLastError:= modbus_rtu_set_rts_delay(fHandle, AValue);
  ExceptCheck;
end;

function    TModBusRtu.GetRtsDelay: Integer;
begin
  Result:= modbus_rtu_get_rts_delay(FHandle);
  ExceptCheck;
end;

constructor TModBusRtu.Create;
begin
  inherited Create;
  {$IFDEF Linux}
    FDevice   := '/dev/ttyS0';
  {$ENDIF}
  {$IFDEF Windows}
    FDevice   := 'COM0';
  {$ENDIF}
    FBaudRate := 9600;
    FDataBits := 8;
    FParity   := 'N';
    FStopBit  := 1;
    {$IFDEF DEBUG}
    Writeln('Create ModBus RTU Master device');
    {$ENDIF}
    ReSettings;
end;

destructor  TModBusRtu.Destroy;
begin
    modbus_free(FHandle);
  inherited Destroy;
end;

procedure TModBusRtu.ReSettings;
begin
  if Assigned(FHandle) then modbus_free(fHandle);
  FHandle:= modbus_new_rtu(Pointer(FDevice), FBaudRate, FParity, FDataBits, FStopBit);
  {$IFDEF DEBUG}
  if Assigned(FHandle) then Self.Debug:= true;
  {$ENDIF}
  if Assigned(FHandle) then FLastError:= 0 else FLastError:= -1;
  ExceptCheck;
end;

{ TDefaultModBus }

procedure   TDefaultModBus.ExceptCheck;
var
  {$IFNDEF DEBUG}{$IFDEF UNIX}
  e: EModBusError;
  {$ENDIF}{$ENDIF}
  s: string;
begin
  {$IFDEF DEBUG}
  s := PChar(modbus_strerror(modbus_errno));
  if (FLastError < 0) then Writeln('Communication error ',modbus_errno,': ',s);
  {$ELSE}
  {$IFDEF UNIX}
  if FRaiseExcept and (FLastError < 0) then
  begin
    s := PChar(modbus_strerror(modbus_errno));
    e := EModBusError.CreateFmt('Communication error %d: %s', [modbus_errno, s]);
    e.ErrorCode := FLastError;
    e.ErrorMessage := s;
    raise e;
  end;
  {$ENDIF}{$ENDIF}
end;

function    TDefaultModBus.GetErrorDesc: String;
begin
  Result:= String(modbus_strerror(modbus_errno));
end;

procedure   TDefaultModBus.SetDebug(AValue: Boolean);
begin
  if AValue
    then FLastError:= modbus_set_debug(FHandle, 1)
    else FLastError:= modbus_set_debug(FHandle, 0);
  ExceptCheck;
end;

function TDefaultModBus.GetDebug: Boolean;
begin
  FLastError:= modbus_get_debug(FHandle);
  Result:= FLastError > 0;
  ExceptCheck;
end;

procedure   TDefaultModBus.SetSlave(AValue: Integer);
begin
  FLastError:= modbus_set_slave(FHandle, AValue);
  ExceptCheck;
end;

function    TDefaultModBus.GetSlave: Integer;
begin
  FLastError := modbus_get_slave(FHandle);
  Result:= FLastError;
  ExceptCheck;
end;

procedure   TDefaultModBus.SetSocet(AValue: Integer);
begin
  FLastError:= modbus_set_socket(FHandle, AValue);
  ExceptCheck;
end;

function    TDefaultModBus.GetSocet: Integer;
begin
  FLastError := modbus_get_socket(FHandle);
  Result:= FLastError;
  ExceptCheck;
end;

procedure   TDefaultModBus.SetResponseTimeOut(AValue: Integer);
var
  sec, usec : Integer;
begin
  sec       := AValue div 1000;
  usec      := (AValue mod 1000)* 1000;
  FLastError:= modbus_set_response_timeout(FHandle, sec, usec);
  ExceptCheck;
end;

function    TDefaultModBus.GetResponseTimeOut: Integer;
var
  sec, usec : Integer;
begin
  FLastError:= modbus_get_response_timeout(FHandle, @sec, @usec);
  Result    := sec * 1000 + usec div 1000;
  ExceptCheck;
end;

procedure   TDefaultModBus.SetBitTimeOut(AValue: Integer);
var
  sec, usec : Integer;
begin
  sec       := AValue div 1000;
  usec      := (AValue mod 1000)* 1000;
  FLastError:= modbus_set_byte_timeout(FHandle, sec, usec);
  ExceptCheck;
end;

function    TDefaultModBus.GetBitTimeOut: Integer;
var
  sec, usec : Integer;
begin
  FLastError:= modbus_get_byte_timeout(FHandle, @sec, @usec);
  Result    := sec * 1000 + usec div 1000;
  ExceptCheck;
end;

procedure TDefaultModBus.SetIndicationTimeOut(AValue: Integer);
var
  sec, usec : Integer;
begin
  sec       := AValue div 1000;
  usec      := (AValue mod 1000)* 1000;
  FLastError:= modbus_set_indication_timeout(FHandle, sec, usec);
  ExceptCheck;
end;

function TDefaultModBus.GetIndicationTimeout: Integer;
var
  sec, usec : Integer;
begin
  FLastError:= modbus_get_indication_timeout(FHandle, @sec, @usec);
  Result    := sec * 1000 + usec div 1000;
  ExceptCheck;
end;

procedure   TDefaultModBus.SetErrorRecovery(AValue: Integer);
begin
  FLastError:= modbus_set_error_recovery(FHandle, AValue);
  ExceptCheck;
end;

function TDefaultModBus.GetErrorRecovery: Integer;
begin
  FLastError:= modbus_get_error_recovery(FHandle);
  Result:= FLastError;
  ExceptCheck;
end;

function    TDefaultModBus.GetHeaderLength: Integer;
begin
  FLastError:= modbus_get_header_length(FHandle);
  Result:= FLastError;
  ExceptCheck;
end;

constructor TDefaultModBus.Create;
begin
  inherited Create;
    FRaiseExcept:= false;
    FConnect    := false;
end;

destructor  TDefaultModBus.Destroy;
begin
  inherited Destroy;
end;

function    TDefaultModBus.ReadBits(const AAddress, ACount: Integer; var Buffer): Integer;
begin
  FLastError:= modbus_read_bits(FHandle, AAddress, ACount, @Buffer);
  Result:= FLastError;
  ExceptCheck;
end;

function    TDefaultModBus.ReadInputBits(const AAddress, ACount: Integer; var Buffer): Integer;
begin
  FLastError:= modbus_read_input_bits(FHandle, AAddress, ACount, @Buffer);
  Result:= FLastError;
  ExceptCheck;
end;

function    TDefaultModBus.ReadRegisters(const AAddress, ACount: Integer; var Buffer): Integer;
begin
  FLastError:= modbus_read_registers(FHandle, AAddress, ACount, @Buffer);
  Result:= FLastError;
  ExceptCheck;
end;

function    TDefaultModBus.ReadInputRegisters(const AAddress, ACount: Integer; var Buffer): Integer;
begin
  FLastError:= modbus_read_input_registers(FHandle, AAddress, aCount, @Buffer);
  Result:= FLastError;
  ExceptCheck;
end;

function    TDefaultModBus.WriteBit(const AAddress : Integer; const Buffer): Integer;
begin
  FLastError:= modbus_write_bit(FHandle, AAddress, Byte(Buffer));
  Result:= FLastError;
  ExceptCheck;
end;

function    TDefaultModBus.WriteRegister(const AAddress: Integer; const Buffer): Integer;
begin
  FLastError:= modbus_write_register(FHandle, AAddress, Integer(Buffer));
  Result:= FLastError;
  ExceptCheck;
end;

function    TDefaultModBus.WriteBits(const AAddress, ACount : Integer; var Buffer): Integer;
begin
  FLastError:= modbus_write_bits(FHandle, AAddress, ACount, @Buffer);
  Result:= FLastError;
  ExceptCheck;
end;

function    TDefaultModBus.WriteRegisters(const AAddress, ACount: Integer; var Buffer): Integer;
begin
  FLastError:= modbus_write_registers(FHandle, AAddress, ACount, @Buffer);
  Result:= FLastError;
  ExceptCheck;
end;

function    TDefaultModBus.MaskWriteRegicter(const AAddress : Integer; const AndMask, OrMask : Word): Integer;
begin
  FLastError:= modbus_mask_write_register(FHandle, AAddress, AndMask, OrMask);
  Result:= FLastError;
  ExceptCheck;
end;

function    TDefaultModBus.WriteAndReadRegisters(const AWriteAddr,
  AWriteCnt: Integer; const Write_Buffer; const AReadAddr,
  AReadCnt: Integer; var Read_Buffer): Integer;
begin
  FLastError:= modbus_write_and_read_registers(FHandle, AWriteAddr, AWriteCnt, @Write_Buffer, AReadAddr, AReadCnt, @Read_Buffer);
  Result:= FLastError;
  ExceptCheck;
end;

function    TDefaultModBus.ReportSlaveId(const ACount: Integer; var Buffer): Integer;
begin
  FLastError:= modbus_report_slave_id(FHandle, ACount, @Buffer);
  Result:= FLastError;
  ExceptCheck;
end;

function    TDefaultModBus.SendRawRequest(const Buffer; const ALength: Integer): Integer;
begin
  FLastError:= modbus_send_raw_request(FHandle, @Buffer, ALength);
  Result:= FLastError;
  ExceptCheck;
end;

function    TDefaultModBus.Flush: Boolean;
begin
  FLastError:= modbus_flush(FHandle);
  Result:= not(FLastError < 0);
  ExceptCheck;
end;

function    TDefaultModBus.Connect: Boolean;
begin
  {$IFDEF DEBUG}
  Writeln('Connected...');
  {$ENDIF}
  FLastError:= modbus_connect(FHandle);
  Result:= not(FLastError < 0);
  FConnect:= Result;
  ExceptCheck;
end;

procedure   TDefaultModBus.Disconnect;
begin
  {$IFDEF DEBUG}
  Writeln('Disconnected...');
  {$ENDIF}
  modbus_close(FHandle);
  FConnect:= false;
end;

function TDefaultModBus.GetErrorDest: String;
begin
  Result:= PChar(modbus_strerror(modbus_errno));
end;

initialization
{$IFNDEF STATIC_LIBMODBUS}
if  not(InitializeModBus) then Halt(1);
{$ELSE}
  //if not(FileExists(Lib_MODBUS)) then Halt(1);
{$ENDIF}
finalization
{$IFNDEF STATIC_LIBMODBUS}
  UnInitializeModBus;
{$ENDIF}
end.

