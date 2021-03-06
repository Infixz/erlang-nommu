%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2007-2014. All Rights Reserved.
%%
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%%
%% %CopyrightEnd%
%%

%%
%%----------------------------------------------------------------------
%% Purpose: Handles an ssl connection, e.i. both the setup
%% e.i. SSL-Handshake, SSL-Alert and SSL-Cipher protocols and delivering
%% data to the application. All data on the connectinon is received and 
%% sent according to the SSL-record protocol.  
%% %%----------------------------------------------------------------------

-module(ssl_alert).

-include("ssl_alert.hrl").
-include("ssl_record.hrl").
-include("ssl_internal.hrl").

-export([encode/3, alert_txt/1, reason_code/2]).

%%====================================================================
%% Internal application API
%%====================================================================

%%--------------------------------------------------------------------
-spec encode(#alert{}, ssl_record:ssl_version(), #connection_states{}) -> 
		    {iolist(), #connection_states{}}.
%%
%% Description: 
%%--------------------------------------------------------------------
encode(#alert{} = Alert, Version, ConnectionStates) ->
    ssl_record:encode_alert_record(Alert, Version, ConnectionStates).

%%--------------------------------------------------------------------
-spec reason_code(#alert{}, client | server) -> closed | {essl, string()}.
%%
%% Description: Returns the error reason that will be returned to the
%% user.
%%--------------------------------------------------------------------

reason_code(#alert{description = ?CLOSE_NOTIFY}, _) ->
    closed;
reason_code(#alert{description = Description}, _) ->
    {tls_alert, description_txt(Description)}.

%%--------------------------------------------------------------------
-spec alert_txt(#alert{}) -> string().
%%
%% Description: Returns the error string for given alert.
%%--------------------------------------------------------------------

alert_txt(#alert{level = Level, description = Description, where = {Mod,Line}}) ->
    Mod ++ ":" ++ integer_to_list(Line) ++ ":" ++ 
	level_txt(Level) ++" "++ description_txt(Description).

%%--------------------------------------------------------------------
%%% Internal functions
%%--------------------------------------------------------------------
level_txt(?WARNING) ->
    "Warning:";
level_txt(?FATAL) ->
    "Fatal error:".

description_txt(?CLOSE_NOTIFY) ->
    "close notify";
description_txt(?UNEXPECTED_MESSAGE) ->
    "unexpected message";
description_txt(?BAD_RECORD_MAC) ->
    "bad record mac";
description_txt(?DECRYPTION_FAILED) ->
    "decryption failed";
description_txt(?RECORD_OVERFLOW) ->
    "record overflow";
description_txt(?DECOMPRESSION_FAILURE) ->
    "decompression failure";
description_txt(?HANDSHAKE_FAILURE) ->
    "handshake failure";
description_txt(?NO_CERTIFICATE_RESERVED) ->
    "No certificate reserved";
description_txt(?BAD_CERTIFICATE) ->
    "bad certificate";
description_txt(?UNSUPPORTED_CERTIFICATE) ->
    "unsupported certificate";
description_txt(?CERTIFICATE_REVOKED) ->
    "certificate revoked";
description_txt(?CERTIFICATE_EXPIRED) ->
    "certificate expired";
description_txt(?CERTIFICATE_UNKNOWN) ->
    "certificate unknown";
description_txt(?ILLEGAL_PARAMETER) ->
    "illegal parameter";
description_txt(?UNKNOWN_CA) ->
    "unknown ca";
description_txt(?ACCESS_DENIED) ->
    "access denied";
description_txt(?DECODE_ERROR) ->
    "decode error";
description_txt(?DECRYPT_ERROR) ->
    "decrypt error";
description_txt(?EXPORT_RESTRICTION) ->
    "export restriction";
description_txt(?PROTOCOL_VERSION) ->
    "protocol version";
description_txt(?INSUFFICIENT_SECURITY) ->
    "insufficient security";
description_txt(?INTERNAL_ERROR) ->
    "internal error";
description_txt(?USER_CANCELED) ->
    "user canceled";
description_txt(?NO_RENEGOTIATION) ->
    "no renegotiation";
description_txt(?UNSUPPORTED_EXTENSION) ->
    "unsupported extension";
description_txt(?CERTIFICATE_UNOBTAINABLE) ->
    "certificate unobtainable";
description_txt(?UNRECOGNISED_NAME) ->
    "unrecognised name";
description_txt(?BAD_CERTIFICATE_STATUS_RESPONSE) ->
    "bad certificate status response";
description_txt(?BAD_CERTIFICATE_HASH_VALUE) ->
    "bad certificate hash value";
description_txt(?UNKNOWN_PSK_IDENTITY) ->
    "unknown psk identity";
description_txt(Enum) ->
    lists:flatten(io_lib:format("unsupported/unknown alert: ~p", [Enum])).
