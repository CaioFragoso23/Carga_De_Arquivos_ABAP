*&---------------------------------------------------------------------*
*& Include          ZFRA_CARGA_V1_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zf_le_arquivo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zf_le_arquivo_ws_upload USING p_file.

*--------------------------------------------------------------------*
  " Função de Upload de Arquivo (Obsoleto)
*--------------------------------------------------------------------*
  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      filename                = p_file
      filetype                = 'ASC'
    TABLES
      data_tab                = it_arq[]
    EXCEPTIONS
      conversion_error        = 1
      file_open_error         = 2
      file_read_error         = 3
      invalid_type            = 4
      no_batch                = 5
      unknown_error           = 6
      invalid_table_width     = 7
      gui_refuse_filetransfer = 8
      customer_error          = 9
      no_authority            = 10
      OTHERS                  = 11.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.

FORM zf_le_hospede.

*--------------------------------------------------------------------*
  " Inserção do hóspede no Banco de Dados
*--------------------------------------------------------------------*
  SELECT MAX( id )
  FROM zfra_hospede
  INTO lv_id.

  PERFORM zf_le_arquivo_ws_upload USING p_file.

  IF sy-subrc EQ 0.   "Caso consiga puxar um arquivo
    LOOP AT it_arq INTO wa_arq.

      SPLIT wa_arq AT ';' INTO wa_tab_hospede-nome
                               wa_tab_hospede-endereco
                               wa_tab_hospede-telefone.

      lv_id = lv_id + 1.
      wa_tab_hospede-id = lv_id.
      APPEND wa_tab_hospede TO it_tab_hospede.

      INSERT INTO zfra_hospede
      VALUES wa_tab_hospede.

    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form zf_le_arquivo_gui_upload
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zf_le_arquivo_gui_upload USING p_path.

*--------------------------------------------------------------------*
  " Método de Upload de Arquivo (Atual)
*--------------------------------------------------------------------*

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = p_path
    CHANGING
      data_tab                = it_arq[]
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.

FORM zf_le_quarto.
*--------------------------------------------------------------------*
  " Função de Inserção do Quarto no Banco de Dados
*--------------------------------------------------------------------*
  SELECT MAX( numero )
  FROM zfra_quarto
  INTO lv_id.

  lv_path = p_file.

  PERFORM zf_le_arquivo_gui_upload USING lv_path.

  IF sy-subrc EQ 0.   "Caso consiga puxar um arquivo

    LOOP AT it_arq INTO wa_arq.
      lv_id = lv_id + 1.
*--------------------------------------------------------------------*
      " Tratamento de campo de preço para inserção no Banco de Dados
*--------------------------------------------------------------------*
      SPLIT wa_arq AT ';' INTO wa_tab_quarto-tipo
                               wa_tab_quarto-preco
                               wa_tab_quarto-moeda.

      REPLACE ',' WITH '.' INTO wa_tab_quarto-preco.
*--------------------------------------------------------------------*

      wa_tab_quarto-numero = lv_id.
      wa_tab_saida_quarto-numero  = wa_tab_quarto-numero.
      wa_tab_saida_quarto-tipo = wa_tab_quarto-tipo.
      wa_tab_saida_quarto-preco = wa_tab_quarto-preco.
      wa_tab_saida_quarto-moeda = wa_tab_quarto-moeda.
      APPEND wa_tab_quarto TO it_tab_quarto.

      INSERT INTO zfra_quarto
      VALUES wa_tab_saida_quarto.

    ENDLOOP.
  ENDIF.
ENDFORM.

FORM zf_le_reservas.

*--------------------------------------------------------------------*
  " Função de Inserção das Reservas no Banco de Dados
*--------------------------------------------------------------------*

  SELECT MAX( id )
  FROM zfra_reservas
  INTO lv_id.

  lv_path = p_file.

  PERFORM zf_le_arquivo_gui_upload USING lv_path.

  IF sy-subrc EQ 0.   "Caso consiga puxar um arquivo
    LOOP AT it_arq INTO wa_arq.
      lv_id = lv_id + 1.

      SPLIT wa_arq AT ';' INTO wa_tab_reservas-checkin
                               wa_tab_reservas-checkout
                               wa_tab_reservas-id_hospede
                               wa_tab_reservas-num_quarto.

*--------------------------------------------------------------------*
      "Tratamento de datas para inserção no banco de dados
*--------------------------------------------------------------------*
      REPLACE ALL OCCURRENCES OF '/' IN wa_tab_reservas-checkin WITH ' '.
      CONDENSE wa_tab_reservas-checkin NO-GAPS.
      CONCATENATE wa_tab_reservas-checkin+4(4) wa_tab_reservas-checkin+2(2) wa_tab_reservas-checkin(2)
      INTO wa_tab_reservas-checkin.


      REPLACE ALL OCCURRENCES OF '/' IN wa_tab_reservas-checkout WITH ' '.
      CONDENSE wa_tab_reservas-checkout NO-GAPS.
      CONCATENATE wa_tab_reservas-checkout+4(4) wa_tab_reservas-checkout+2(2) wa_tab_reservas-checkout(2)
      INTO wa_tab_reservas-checkout.
*--------------------------------------------------------------------*


      wa_tab_reservas-id = lv_id.
      APPEND wa_tab_reservas TO it_tab_reservas.
      CLEAR wa_tab_reservas.

      LOOP AT it_tab_reservas INTO wa_tab_reservas.

        wa_tab_saida_reservas-id = wa_tab_reservas-id.
        wa_tab_saida_reservas-checkin = wa_tab_reservas-checkin.
        wa_tab_saida_reservas-checkout = wa_tab_reservas-checkout.
        wa_tab_saida_reservas-id_hospede = wa_tab_reservas-id_hospede.
        wa_tab_saida_reservas-num_quarto = wa_tab_reservas-num_quarto.
        APPEND wa_tab_saida_reservas TO it_tab_saida_reservas.
        INSERT INTO zfra_reservas
        VALUES wa_tab_saida_reservas.

      ENDLOOP.

    ENDLOOP.
  ENDIF.
ENDFORM.
