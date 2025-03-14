namespace KolosDemo.KolosDemo;
using System.Text;
using Microsoft.Sales.Customer;
using System.Utilities;
using Microsoft.Foundation.Company;
using Microsoft.Sales.History;
using Microsoft.Sales.Document;

codeunit 60004 MRAEInvoice
{

    SingleInstance = true;
    Permissions = TableData 112 = rimd, tabledata 114 = RIMD;
    //Permissions = TableData 112 = rimd;
    // 

    //EventSubscriberInstance = Manual;
    trigger OnRun();
    begin
        //GenerateIRN(Rec);
    end;

    ///////////////////// Generate IRN ///////////////////////
    //procedure GenerateIRN(var SIHRec: Record "Sales Invoice Header");
    procedure GenerateIRNSingle(var SIHRec: Record "Sales Invoice Header"; invoiceTypeDesc: Code[20]);
    var
        //CD: Codeunit "Rest API Codeunit";
        MraApiRec: Record "Mra Api Setup";
        EInvoiceFindRec: Record EInvoice;
        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        IrnStr: Text;
        messageStr: Text;
        AckDtStr: Text;
        AckDtDt: DateTime;
        AckNoStr: Text;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;

    begin
        MraApiRec.Reset();
        MraApiRec.SetRange("Code", 'EINVOICE');
        MraApiRec.SetRange(ActiveYN, true);
        if MraApiRec.FindFirst() then begin
            MraApiRec.TestField(EbsMraUsername);
            MraApiRec.TestField(EbsMraPasswor);
            MraApiRec.TestField(EbsMraId);
            MraApiRec.TestField(areaCode);
            MraApiRec.TestField(UrlToken);
            MraApiRec.TestField(UrlTransmit);
            MraApiRec.TestField(ThirdPartyUrl);
            url := MraApiRec.ThirdPartyUrl;

        end else begin
            Error('MRA Setup API not found with below filter-\' + MraApiRec.GetFilters());
        end;

        JsonPayLoad := CreateJSONForEInvoiceSingle(SIHRec, invoiceTypeDesc);
        //JsonPayLoad := '[{"invoiceCounter":"1","transactionType":"B2C","personType":"VATR","invoiceTypeDesc":"DRN","currency":"MUR","invoiceIdentifier":"test3","invoiceRefIdentifier":"test1","reasonStated":"return of product","previousNoteHash":"prevNote","totalVatAmount":"30","totalAmtWoVatCur":"310.01","totalAmtWoVatMur":"10.1","totalAmtPaid":"6400","invoiceTotal":"6700","discountTotalAmount":"300","dateTimeInvoiceIssued":"20221012 10:40:30","seller":{"name":"Test User","tradeName":"KOLOS","tan":"20157766","brn":"C06017125","businessAddr":"3Port Louis","businessPhoneNo":"","ebsCounterNo":"a1"},"buyer":{"name":"Testing use 2","tan":"20484367","brn":"C08085083","businessAddr":"Quatre Bornes","buyerType":"VATR","nic":""},"itemList":[{"taxCode":"TC01","nature":"GOODS","currency":"MUR","itemNo":"10000","productCodeMra":"pdtCode","productCodeOwn":"pdtOwn","itemDesc":"2","quantity":"3","unitPrice":"20","discount":"0","discountedValue":"10.1","amtWoVatCur":"600","amtWoVatMur":"50","vatAmt":"10","totalPrice":"60"}],"salesTransactions":"CASH"}]';
        Message('Request\' + JsonPayLoad);
        //exit; //MC101024 //261224  
        // Add the payload to the content
        //content.WriteFrom(JsonPayLoad);
        content.WriteFrom(JsonPayLoad);


        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Username', MraApiRec.EbsMraUsername);
        contentHeaders.Add('Ebsmraid', MraApiRec.EbsMraId);
        contentHeaders.Add('Areacode', Format(MraApiRec.areaCode));
        contentHeaders.Add('Ebsmrapassword', MraApiRec.EbsMraPasswor);
        contentHeaders.Add('UrlToken', MraApiRec.UrlToken);
        contentHeaders.Add('UrlTransmit', MraApiRec.UrlTransmit);

        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('irn', IrnStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('qrCode', SignedQRCodeStr);
        // Message('IRN=%1\ QR Code=%2\ Status=%3', IrnStr, SignedQRCodeStr, statusStr);
        EInvoiceHistorRecFind.Reset();
        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SIHRec."No.";
        //Request Text
        //Message('JsonPayLoad', JsonPayLoad);
        //SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        //SetResponseText(EInvoiceHistorRec, responseText);

        EInvoiceHistorRec.Insert(true);
        //Request
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Response
        SetResponseText(EInvoiceHistorRec, responseText);



        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Generate E-Invoice";

        if statusStr = 'SUCCESS' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);



        // Store Success IRN 
        EntryNo := 0;
        if statusStr = 'SUCCESS' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;
            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SIHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec.IRN := IrnStr;
            Evaluate(AckDtDt, AckDtStr);
            EInvoiceRec.AckDt := AckDtDt;
            EInvoiceRec."AckNo." := AckNoStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Generate E-Invoice";
            EInvoiceRec.Insert(true);
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            SIHRec.IRN := IrnStr;
            SIHRec.EInvoiceStatus := SIHRec.EInvoiceStatus::Accepted;
            SIHRec.ErrorText := messageStr;
            //SIHRec."Acknowledgement Date" := AckDtDt;
            //SIHRec."Acknowledgement No." := AckNoStr;
            SIHRec.Modify(True);

            Message('E-Invoice Generated Successfully Inv No. %1 and IRN %2', SIHRec."No.", IrnStr);
        end else begin
            SIHRec.IRN := IrnStr;
            SIHRec.EInvoiceStatus := SIHRec.EInvoiceStatus::Pending;
            if StrLen(messageStr) > 1024 then begin
                SIHRec.ErrorText := CopyStr(messageStr, 1, 1023);
            end else begin
                SIHRec.ErrorText := messageStr;
            end;
            SIHRec.Modify(True);
            Message(responseText);
        end;

    end;


    procedure GenerateIRNMultiple(var SIHRec: Record "Sales Invoice Header"; invoiceTypeDesc: Code[20]);
    var
        //CD: Codeunit "Rest API Codeunit";
        MraApiRec: Record "Mra Api Setup";
        EInvoiceFindRec: Record EInvoice;
        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        IrnStr: Text;
        messageStr: Text;
        AckDtStr: Text;
        AckDtDt: DateTime;
        AckNoStr: Text;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;
        SelectedInvoices: Text;

    begin
        MraApiRec.Reset();
        MraApiRec.SetRange("Code", 'EINVOICE');
        MraApiRec.SetRange(ActiveYN, true);
        if MraApiRec.FindFirst() then begin
            MraApiRec.TestField(EbsMraUsername);
            MraApiRec.TestField(EbsMraPasswor);
            MraApiRec.TestField(EbsMraId);
            MraApiRec.TestField(areaCode);
            MraApiRec.TestField(UrlToken);
            MraApiRec.TestField(UrlTransmit);
            MraApiRec.TestField(ThirdPartyUrl);
            url := MraApiRec.ThirdPartyUrl;

        end else begin
            Error('MRA Setup API not found with below filter-\' + MraApiRec.GetFilters());
        end;

        if SIHRec.FindSet() then begin
            repeat
                // Collect selected invoice numbers
                //SelectedInvoices += SIHRec."No." + ', ';
                JsonPayLoad += CreateJSONForEInvoiceMultiple(SIHRec, invoiceTypeDesc) + ',';
            until SIHRec.Next() = 0;
            if CopyStr(JsonPayLoad, StrLen(JsonPayLoad), 1) = ',' then
                JsonPayLoad := '[' + DelStr(JsonPayLoad, StrLen(JsonPayLoad), 1) + ']';
            //Message('Selected Invoice Numbers: ' + SelectedInvoices);
        end else begin
            Message('No invoices selected.');
            exit;
        end;

        //JsonPayLoad := CreateJSONForEInvoiceMultiple(SIHRec, invoiceTypeDesc);
        //JsonPayLoad := '[{"invoiceCounter":"1","transactionType":"B2C","personType":"VATR","invoiceTypeDesc":"DRN","currency":"MUR","invoiceIdentifier":"test3","invoiceRefIdentifier":"test1","reasonStated":"return of product","previousNoteHash":"prevNote","totalVatAmount":"30","totalAmtWoVatCur":"310.01","totalAmtWoVatMur":"10.1","totalAmtPaid":"6400","invoiceTotal":"6700","discountTotalAmount":"300","dateTimeInvoiceIssued":"20221012 10:40:30","seller":{"name":"Test User","tradeName":"KOLOS","tan":"20157766","brn":"C06017125","businessAddr":"3Port Louis","businessPhoneNo":"","ebsCounterNo":"a1"},"buyer":{"name":"Testing use 2","tan":"20484367","brn":"C08085083","businessAddr":"Quatre Bornes","buyerType":"VATR","nic":""},"itemList":[{"taxCode":"TC01","nature":"GOODS","currency":"MUR","itemNo":"10000","productCodeMra":"pdtCode","productCodeOwn":"pdtOwn","itemDesc":"2","quantity":"3","unitPrice":"20","discount":"0","discountedValue":"10.1","amtWoVatCur":"600","amtWoVatMur":"50","vatAmt":"10","totalPrice":"60"}],"salesTransactions":"CASH"}]';
        Message('Request\' + JsonPayLoad);
        //exit; //MC101024 //261224
        // Add the payload to the content
        //content.WriteFrom(JsonPayLoad);
        content.WriteFrom(JsonPayLoad);
        //exit;

        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Username', MraApiRec.EbsMraUsername);
        contentHeaders.Add('Ebsmraid', MraApiRec.EbsMraId);
        contentHeaders.Add('Areacode', Format(MraApiRec.areaCode));
        contentHeaders.Add('Ebsmrapassword', MraApiRec.EbsMraPasswor);
        contentHeaders.Add('UrlToken', MraApiRec.UrlToken);
        contentHeaders.Add('UrlTransmit', MraApiRec.UrlTransmit);

        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('irn', IrnStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('qrCode', SignedQRCodeStr);
        // Message('IRN=%1\ QR Code=%2\ Status=%3', IrnStr, SignedQRCodeStr, statusStr);

        //FC 120325
        if SIHRec.FindFirst() then begin //FC
            repeat //FC

                //*************** History ********
                EInvoiceHistorRecFind.Reset();
                if EInvoiceHistorRecFind.FindLast() then
                    EntryNo := EInvoiceHistorRecFind."Entry No." + 1
                else
                    EntryNo := 1;

                EInvoiceHistorRec.Init();
                EInvoiceHistorRec."Entry No." := EntryNo;
                EInvoiceHistorRec."Document No." := SIHRec."No.";
                //Request Text
                //Message('JsonPayLoad', JsonPayLoad);
                //SetRequestText(EInvoiceHistorRec, JsonPayLoad);
                //Request Text
                //SetResponseText(EInvoiceHistorRec, responseText);

                EInvoiceHistorRec.Insert(true);
                //Request
                SetRequestText(EInvoiceHistorRec, JsonPayLoad);
                //Response
                SetResponseText(EInvoiceHistorRec, responseText);



                EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Generate E-Invoice";

                if statusStr = 'SUCCESS' then begin
                    EInvoiceHistorRec.Status := true;
                end;
                EInvoiceHistorRec.Modify(true);



                // ****** Store Success IRN *******
                if statusStr = 'SUCCESS' then begin
                    if EInvoiceFindRec.FindLast() then
                        EntryNo := EInvoiceFindRec."Entry No." + 1
                    else
                        EntryNo := 1;

                    EInvoiceRec.Init();
                    EInvoiceRec."Entry No." := EntryNo;
                    EInvoiceRec."No." := SIHRec."No.";
                    EInvoiceRec.Status := statusStr;
                    EInvoiceRec.IRN := IrnStr;
                    Evaluate(AckDtDt, AckDtStr);
                    EInvoiceRec.AckDt := AckDtDt;
                    EInvoiceRec."AckNo." := AckNoStr;
                    EInvoiceRec.SignedQRCode := SignedQRCodeStr;
                    //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
                    EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Generate E-Invoice";
                    EInvoiceRec.Insert(true);
                    SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

                    SIHRec.IRN := IrnStr;
                    SIHRec.EInvoiceStatus := SIHRec.EInvoiceStatus::Accepted;
                    SIHRec.ErrorText := messageStr;
                    //SIHRec."Acknowledgement Date" := AckDtDt;
                    //SIHRec."Acknowledgement No." := AckNoStr;
                    SIHRec.Modify(True);

                    Message('E-Invoice Generated Successfully Inv No. %1 and IRN %2', SIHRec."No.", IrnStr);
                end else begin
                    SIHRec.IRN := IrnStr;
                    SIHRec.EInvoiceStatus := SIHRec.EInvoiceStatus::Pending;
                    if StrLen(messageStr) > 1024 then begin
                        SIHRec.ErrorText := CopyStr(messageStr, 1, 1023);
                    end else begin
                        SIHRec.ErrorText := messageStr;
                    end;
                    SIHRec.Modify(True);
                    Message(responseText);
                end;
            until SIHRec.Next = 0; //FC
        end; //FC


    end;

    procedure SetRequestText(var EInvoiceHistroyRec: Record EInvoiceHistory; RequestText: Text)
    var
        OutStream: OutStream;
    begin
        Clear(EInvoiceHistroyRec."Request Text");
        // EInvoiceHistroyRec."Request Text":= RequestText;
        EInvoiceHistroyRec."Request Text".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(RequestText);
        EInvoiceHistroyRec.Modify(True);
    end;

    procedure SetResponseText(var EInvoiceHistroyRec: Record EInvoiceHistory; ResponseText: Text)
    var
        OutStream: OutStream;
    begin
        Clear(EInvoiceHistroyRec."Response Text");
        EInvoiceHistroyRec."Response Text".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(ResponseText);
        EInvoiceHistroyRec.Modify(True);
    end;

    procedure SetSignedInvoiceText(var EInvoiceRec: Record EInvoice; SignedInvoiceText: Text)
    var
        OutStream: OutStream;
    begin
        Clear(EInvoiceRec.SignedInvoice);
        EInvoiceRec.SignedInvoice.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(SignedInvoiceText);
        EInvoiceRec.Modify(True);
    end;

    /////////////////////MA08MARCH2025////////////////////
    local procedure CreateJSONForEInvoiceSingle(SIHRec: Record "Sales Invoice Header"; invoiceTypeDesc: Code[20]): Text;
    var
        SILRec: Record "Sales Invoice Line";
        CompRec: Record "Company Information";
        //StateRec: Record State;
        CustRec: Record Customer;
        //DetailedGSTLedgerEntryRec: Record "Detailed GST Ledger Entry";
        TotItemVal: Decimal;
        G_TotItemVal: Decimal;
        StringConversionManagementCU: Codeunit StringConversionManagement;

        G_AssVal: Decimal;
        G_CgstVal: Decimal;
        G_SgstVal: Decimal;
        G_IgstVal: Decimal;

        Cnt: Integer;
        SellerDtls_Stcd: Code[20];
        BuyerDtls_Stcd: code[20];
        TranDtls: JsonObject;
        JsonData: Text;
        MainJson: JsonObject;
        DocDtls: JsonObject;
        SellerDtls: JsonObject;
        BuyerDtls: JsonObject;
        DispDtls: JsonObject;
        ShipDtls: JsonObject;
        ItemListArr: JsonArray;
        ItemList: JsonObject;
        ValDtls: JsonObject;
        SellerDtlsPin: Integer;
        BuyerDtlsPin: Integer;
        DispDtlsPin: Integer;
        ShipDtlsPin: Integer;
        Ln: Integer;
        ItemNo: Code[20];
        ItemCode: Integer;
        //MC18FEB2025
        JsonObject: JsonObject;
        Seller, Buyer : JsonObject;
        ItemArray: JsonArray;
        Item: JsonObject;
        JsonText: Text;
        JsonOutput: OutStream;
        JsonInput: InStream;
        TempBlob: Codeunit "Temp Blob";
        DateTimeString: Text;
        PostingDateTime: DateTime;
        BalanceStr: Text;
    //MC18FEB2025
    Begin
        Clear(TranDtls);
        Clear(DocDtls);
        Clear(SellerDtls);
        Clear(BuyerDtls);
        Clear(DispDtls);
        Clear(ShipDtls);
        Clear(ItemListArr);
        Clear(ItemList);
        Clear(ValDtls);
        Clear(TempBlob);
        ////////// Get Sellr Detl////////
        SellerDtls_Stcd := '';
        if CompRec.get() THEN;
        if CustRec.get(SIHRec."Sell-to Customer No.") then;
        // MC18022025
        JsonObject.Add('invoiceCounter', '1');
        JsonObject.Add('transactionType', 'B2C');
        JsonObject.Add('personType', 'VATR');
        JsonObject.Add('invoiceTypeDesc', invoiceTypeDesc); //STD
        JsonObject.Add('currency', 'MUR');
        JsonObject.Add('invoiceIdentifier', SIHRec."No.");
        JsonObject.Add('invoiceRefIdentifier', '');
        JsonObject.Add('previousNoteHash', 'prevNote');
        JsonObject.Add('reasonStated', 'rgeegr');
        JsonObject.Add('totalVatAmount', SIHRec."Amount Including VAT"); //Ma
        JsonObject.Add('totalAmtWoVatCur', SIHRec."Amount");
        JsonObject.Add('totalAmtWoVatMur', SIHRec."Amount");
        JsonObject.Add('invoiceTotal', SIHRec."Amount Including VAT");
        JsonObject.Add('discountTotalAmount', SIHRec."Invoice Discount Amount");
        JsonObject.Add('totalAmtPaid', SIHRec."Amount Including VAT"); //MA08MAR2025
        PostingDateTime := CreateDateTime(SIHRec."Posting Date", 000000T); // Convert Posting Date to DateTime
        DateTimeString := Format(Date2DMY(SIHRec."Posting Date", 3));
        // for month
        if Date2DMY(SIHRec."Posting Date", 2) <= 9 then begin
            DateTimeString += '0' + Format(Date2DMY(SIHRec."Posting Date", 2));
        end else begin
            DateTimeString += Format(Date2DMY(SIHRec."Posting Date", 2));
        end;
        // for day
        if Date2DMY(SIHRec."Posting Date", 1) <= 9 then begin
            DateTimeString += '0' + Format(Date2DMY(SIHRec."Posting Date", 1));
        end else begin
            DateTimeString += Format(Date2DMY(SIHRec."Posting Date", 1));
        end;

        DateTimeString += ' 00:00:00';

        JsonObject.Add('dateTimeInvoiceIssued', DateTimeString);


        // Seller Details
        Seller.Add('name', 'Test User');
        Seller.Add('tradeName', CompRec.Name);
        Seller.Add('tan', CompRec.TAN);
        Seller.Add('brn', CompRec.BRN);
        Seller.Add('businessAddr', CompRec.Address);
        Seller.Add('businessPhoneNo', CompRec."Phone No.");
        Seller.Add('ebsCounterNo', 'a1');
        JsonObject.Add('seller', Seller);

        // Buyer Details
        Buyer.Add('name', CustRec.Name);
        Buyer.Add('tan', CustRec.TAN);
        Buyer.Add('brn', CustRec.BRN);
        Buyer.Add('businessAddr', CustRec.Address);
        Buyer.Add('buyerType', 'VATR');
        Buyer.Add('nic', '');
        JsonObject.Add('buyer', Buyer);

        // Loop through Sales Invoice Lines
        SILRec.SetRange("Document No.", SIHRec."No.");
        SILRec.SetFilter(Quantity, '<>%1', 0);
        SILRec.SetFilter("No.", '<>%1', '');
        SILRec.SetFilter("Line Amount", '<>%1', 0);
        if SILRec.FindSet() then
            repeat
                Clear(Item);
                Item.Add('itemNo', Format(SILRec."Line No."));
                Item.Add('taxCode', 'TC01');
                if SILRec.Type = SILRec.Type::Item then begin
                    Item.Add('nature', 'GOODS');

                end else begin
                    Item.Add('nature', 'GOODS');
                end;

                Item.Add('productCodeMra', 'pdtCode');
                Item.Add('productCodeOwn', 'pdtOwn');
                Item.Add('itemDesc', SILRec.Description);
                Item.Add('quantity', Format(SILRec.Quantity));

                BalanceStr := Format((SILRec."Unit Price"));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('unitPrice', BalanceStr);


                Item.Add('discount', SILRec."Line Discount %"); // Replace with actual discount if applicable
                Item.Add('discountedValue', SILRec."Line Discount Amount"); //MA08MAR2025
                BalanceStr := Format((SILRec.Amount));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('amtWoVatCur', BalanceStr);

                BalanceStr := Format((SILRec.Amount));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('amtWoVatMur', BalanceStr);

                BalanceStr := Format((SILRec."VAT %"));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('vatAmt', BalanceStr);

                // Item.Add('vatAmt', Format(SILRec."VAT %", 0, '0.00'));
                BalanceStr := Format((SILRec."Line Amount"));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('totalPrice', BalanceStr);

                ItemArray.Add(Item);
            until SILRec.Next() = 0;

        JsonObject.Add('itemList', ItemArray);
        JsonObject.Add('salesTransactions', 'CASH');

        // Convert JSON to Text using InStream
        Clear(TempBlob);
        TempBlob.CreateOutStream(JsonOutput);
        JsonObject.WriteTo(JsonOutput);

        TempBlob.CreateInStream(JsonInput);
        JsonInput.ReadText(JsonText);
        JsonText := '[' + JsonText + ']';

        exit(JsonText);

    end;


    local procedure CreateJSONForEInvoiceMultiple(var SIHRec: Record "Sales Invoice Header"; invoiceTypeDesc: Code[20]): Text;
    var
        SILRec: Record "Sales Invoice Line";
        CompRec: Record "Company Information";
        //StateRec: Record State;
        CustRec: Record Customer;
        //DetailedGSTLedgerEntryRec: Record "Detailed GST Ledger Entry";
        TotItemVal: Decimal;
        G_TotItemVal: Decimal;
        StringConversionManagementCU: Codeunit StringConversionManagement;

        G_AssVal: Decimal;
        G_CgstVal: Decimal;
        G_SgstVal: Decimal;
        G_IgstVal: Decimal;

        Cnt: Integer;
        SellerDtls_Stcd: Code[20];
        BuyerDtls_Stcd: code[20];
        TranDtls: JsonObject;
        JsonData: Text;
        MainJson: JsonObject;
        DocDtls: JsonObject;
        SellerDtls: JsonObject;
        BuyerDtls: JsonObject;
        DispDtls: JsonObject;
        ShipDtls: JsonObject;
        ItemListArr: JsonArray;
        ItemList: JsonObject;
        ValDtls: JsonObject;
        SellerDtlsPin: Integer;
        BuyerDtlsPin: Integer;
        DispDtlsPin: Integer;
        ShipDtlsPin: Integer;
        Ln: Integer;
        ItemNo: Code[20];
        ItemCode: Integer;
        //MC18FEB2025
        JsonObject: JsonObject;
        Seller, Buyer : JsonObject;
        ItemArray: JsonArray;
        Item: JsonObject;
        JsonText: Text;
        JsonOutput: OutStream;
        JsonInput: InStream;
        TempBlob: Codeunit "Temp Blob";
        DateTimeString: Text;
        PostingDateTime: DateTime;
        BalanceStr: Text;
    //MC18FEB2025
    Begin
        Clear(TranDtls);
        Clear(DocDtls);
        Clear(SellerDtls);
        Clear(BuyerDtls);
        Clear(DispDtls);
        Clear(ShipDtls);
        Clear(ItemListArr);
        Clear(ItemList);
        Clear(ValDtls);
        Clear(TempBlob);
        ////////// Get Sellr Detl////////
        SellerDtls_Stcd := '';
        if CompRec.get() THEN;
        if CustRec.get(SIHRec."Sell-to Customer No.") then;
        // MC18022025
        JsonObject.Add('invoiceCounter', '1');
        JsonObject.Add('transactionType', 'B2C');
        JsonObject.Add('personType', 'VATR');
        JsonObject.Add('invoiceTypeDesc', invoiceTypeDesc); //STD
        JsonObject.Add('currency', 'MUR');
        JsonObject.Add('invoiceIdentifier', SIHRec."No.");
        JsonObject.Add('invoiceRefIdentifier', '');
        JsonObject.Add('previousNoteHash', 'prevNote');
        JsonObject.Add('reasonStated', 'rgeegr');
        JsonObject.Add('totalVatAmount', SIHRec."Amount Including VAT"); //Ma
        JsonObject.Add('totalAmtWoVatCur', SIHRec."Amount");
        JsonObject.Add('totalAmtWoVatMur', SIHRec."Amount");
        JsonObject.Add('invoiceTotal', SIHRec."Amount Including VAT");
        JsonObject.Add('discountTotalAmount', SIHRec."Invoice Discount Amount");
        JsonObject.Add('totalAmtPaid', SIHRec."Amount Including VAT"); //MA08MAR2025
        PostingDateTime := CreateDateTime(SIHRec."Posting Date", 000000T); // Convert Posting Date to DateTime
        DateTimeString := Format(Date2DMY(SIHRec."Posting Date", 3));
        // for month
        if Date2DMY(SIHRec."Posting Date", 2) <= 9 then begin
            DateTimeString += '0' + Format(Date2DMY(SIHRec."Posting Date", 2));
        end else begin
            DateTimeString += Format(Date2DMY(SIHRec."Posting Date", 2));
        end;
        // for day
        if Date2DMY(SIHRec."Posting Date", 1) <= 9 then begin
            DateTimeString += '0' + Format(Date2DMY(SIHRec."Posting Date", 1));
        end else begin
            DateTimeString += Format(Date2DMY(SIHRec."Posting Date", 1));
        end;

        DateTimeString += ' 00:00:00';

        JsonObject.Add('dateTimeInvoiceIssued', DateTimeString);


        // Seller Details
        Seller.Add('name', 'Test User');
        Seller.Add('tradeName', CompRec.Name);
        Seller.Add('tan', CompRec.TAN);
        Seller.Add('brn', CompRec.BRN);
        Seller.Add('businessAddr', CompRec.Address);
        Seller.Add('businessPhoneNo', CompRec."Phone No.");
        Seller.Add('ebsCounterNo', 'a1');
        JsonObject.Add('seller', Seller);

        // Buyer Details
        Buyer.Add('name', CustRec.Name);
        Buyer.Add('tan', CustRec.TAN);
        Buyer.Add('brn', CustRec.BRN);
        Buyer.Add('businessAddr', CustRec.Address);
        Buyer.Add('buyerType', 'VATR');
        Buyer.Add('nic', '');
        JsonObject.Add('buyer', Buyer);

        // Loop through Sales Invoice Lines
        SILRec.SetRange("Document No.", SIHRec."No.");
        SILRec.SetFilter(Quantity, '<>%1', 0);
        SILRec.SetFilter("No.", '<>%1', '');
        SILRec.SetFilter("Line Amount", '<>%1', 0);
        if SILRec.FindSet() then
            repeat
                Clear(Item);
                Item.Add('itemNo', Format(SILRec."Line No."));
                Item.Add('taxCode', 'TC01');
                if SILRec.Type = SILRec.Type::Item then begin
                    Item.Add('nature', 'GOODS');

                end else begin
                    Item.Add('nature', 'GOODS');
                end;

                Item.Add('productCodeMra', 'pdtCode');
                Item.Add('productCodeOwn', 'pdtOwn');
                Item.Add('itemDesc', SILRec.Description);
                Item.Add('quantity', Format(SILRec.Quantity));

                BalanceStr := Format((SILRec."Unit Price"));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('unitPrice', BalanceStr);


                Item.Add('discount', SILRec."Line Discount %"); // Replace with actual discount if applicable
                Item.Add('discountedValue', SILRec."Line Discount Amount"); //MA08MAR2025
                BalanceStr := Format((SILRec.Amount));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('amtWoVatCur', BalanceStr);

                BalanceStr := Format((SILRec.Amount));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('amtWoVatMur', BalanceStr);

                BalanceStr := Format((SILRec."VAT %"));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('vatAmt', BalanceStr);

                // Item.Add('vatAmt', Format(SILRec."VAT %", 0, '0.00'));
                BalanceStr := Format((SILRec."Line Amount"));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('totalPrice', BalanceStr);

                ItemArray.Add(Item);
            until SILRec.Next() = 0;

        JsonObject.Add('itemList', ItemArray);
        JsonObject.Add('salesTransactions', 'CASH');

        // Convert JSON to Text using InStream
        Clear(TempBlob);
        TempBlob.CreateOutStream(JsonOutput);
        JsonObject.WriteTo(JsonOutput);

        TempBlob.CreateInStream(JsonInput);
        JsonInput.ReadText(JsonText);
        //JsonText := '[' + JsonText + ']';

        exit(JsonText);

    end;


    procedure GenerateIRNSalesCreditSingle(var SCHRec: Record "Sales Cr.Memo Header"; invoiceTypeDesc: Code[20]);
    var
        //CD: Codeunit "Rest API Codeunit";
        MraApiRec: Record "Mra Api Setup";
        EInvoiceFindRec: Record EInvoice;
        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        IrnStr: Text;
        messageStr: Text;
        AckDtStr: Text;
        AckDtDt: DateTime;
        AckNoStr: Text;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;

    begin
        MraApiRec.Reset();
        MraApiRec.SetRange("Code", 'EINVOICE');
        MraApiRec.SetRange(ActiveYN, true);
        if MraApiRec.FindFirst() then begin
            MraApiRec.TestField(EbsMraUsername);
            MraApiRec.TestField(EbsMraPasswor);
            MraApiRec.TestField(EbsMraId);
            MraApiRec.TestField(areaCode);
            MraApiRec.TestField(UrlToken);
            MraApiRec.TestField(UrlTransmit);
            MraApiRec.TestField(ThirdPartyUrl);
            url := MraApiRec.ThirdPartyUrl;

        end else begin
            Error('MRA Setup API not found with below filter-\' + MraApiRec.GetFilters());
        end;

        JsonPayLoad := CreateJSONForEInvoiceSalesCreditSingle(SCHRec, invoiceTypeDesc);
        //JsonPayLoad := '[{"invoiceCounter":"1","transactionType":"B2C","personType":"VATR","invoiceTypeDesc":"DRN","currency":"MUR","invoiceIdentifier":"test3","invoiceRefIdentifier":"test1","reasonStated":"return of product","previousNoteHash":"prevNote","totalVatAmount":"30","totalAmtWoVatCur":"310.01","totalAmtWoVatMur":"10.1","totalAmtPaid":"6400","invoiceTotal":"6700","discountTotalAmount":"300","dateTimeInvoiceIssued":"20221012 10:40:30","seller":{"name":"Test User","tradeName":"KOLOS","tan":"20157766","brn":"C06017125","businessAddr":"3Port Louis","businessPhoneNo":"","ebsCounterNo":"a1"},"buyer":{"name":"Testing use 2","tan":"20484367","brn":"C08085083","businessAddr":"Quatre Bornes","buyerType":"VATR","nic":""},"itemList":[{"taxCode":"TC01","nature":"GOODS","currency":"MUR","itemNo":"10000","productCodeMra":"pdtCode","productCodeOwn":"pdtOwn","itemDesc":"2","quantity":"3","unitPrice":"20","discount":"0","discountedValue":"10.1","amtWoVatCur":"600","amtWoVatMur":"50","vatAmt":"10","totalPrice":"60"}],"salesTransactions":"CASH"}]';
        Message('Request\' + JsonPayLoad);
        //exit; //MC101024 //261224
        // Add the payload to the content
        //content.WriteFrom(JsonPayLoad);
        content.WriteFrom(JsonPayLoad);


        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Username', MraApiRec.EbsMraUsername);
        contentHeaders.Add('Ebsmraid', MraApiRec.EbsMraId);
        contentHeaders.Add('Areacode', Format(MraApiRec.areaCode));
        contentHeaders.Add('Ebsmrapassword', MraApiRec.EbsMraPasswor);
        contentHeaders.Add('UrlToken', MraApiRec.UrlToken);
        contentHeaders.Add('UrlTransmit', MraApiRec.UrlTransmit);

        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('irn', IrnStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('qrCode', SignedQRCodeStr);
        // Message('IRN=%1\ QR Code=%2\ Status=%3', IrnStr, SignedQRCodeStr, statusStr);
        EInvoiceHistorRecFind.Reset();
        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SCHRec."No.";
        //Request Text
        //Message('JsonPayLoad', JsonPayLoad);
        //SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        //SetResponseText(EInvoiceHistorRec, responseText);

        EInvoiceHistorRec.Insert(true);
        //Request
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Response
        SetResponseText(EInvoiceHistorRec, responseText);



        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Generate Sales Credit Note";

        if statusStr = 'SUCCESS' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);



        // Store Success IRN 
        EntryNo := 0;
        if statusStr = 'SUCCESS' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;
            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SCHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec.IRN := IrnStr;
            Evaluate(AckDtDt, AckDtStr);
            EInvoiceRec.AckDt := AckDtDt;
            EInvoiceRec."AckNo." := AckNoStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Generate E-Invoice";
            EInvoiceRec.Insert(true);
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            SCHRec.IRN := IrnStr;
            SCHRec.EInvoiceStatus := SCHRec.EInvoiceStatus::Accepted;
            SCHRec.ErrorText := messageStr;
            //SIHRec."Acknowledgement Date" := AckDtDt;
            //SIHRec."Acknowledgement No." := AckNoStr;
            SCHRec.Modify(True);

            Message('E-Invoice Generated Successfully Sales Credit Memo No. %1 and IRN %2', SCHRec."No.", IrnStr);
        end else begin
            SCHRec.IRN := IrnStr;
            SCHRec.EInvoiceStatus := SCHRec.EInvoiceStatus::Pending;
            if StrLen(messageStr) > 1024 then begin
                SCHRec.ErrorText := CopyStr(messageStr, 1, 1023);
            end else begin
                SCHRec.ErrorText := messageStr;
            end;
            SCHRec.Modify(True);
            Message(responseText);
        end;

    end;


    local procedure CreateJSONForEInvoiceSalesCreditSingle(SCHRec: Record "Sales Cr.Memo Header"; invoiceTypeDesc: Code[20]): Text;
    var
        SCLRec: Record "Sales Cr.Memo Line";
        CompRec: Record "Company Information";
        //StateRec: Record State;
        CustRec: Record Customer;
        //DetailedGSTLedgerEntryRec: Record "Detailed GST Ledger Entry";
        TotItemVal: Decimal;
        G_TotItemVal: Decimal;
        StringConversionManagementCU: Codeunit StringConversionManagement;

        G_AssVal: Decimal;
        G_CgstVal: Decimal;
        G_SgstVal: Decimal;
        G_IgstVal: Decimal;

        Cnt: Integer;
        SellerDtls_Stcd: Code[20];
        BuyerDtls_Stcd: code[20];
        TranDtls: JsonObject;
        JsonData: Text;
        MainJson: JsonObject;
        DocDtls: JsonObject;
        SellerDtls: JsonObject;
        BuyerDtls: JsonObject;
        DispDtls: JsonObject;
        ShipDtls: JsonObject;
        ItemListArr: JsonArray;
        ItemList: JsonObject;
        ValDtls: JsonObject;
        SellerDtlsPin: Integer;
        BuyerDtlsPin: Integer;
        DispDtlsPin: Integer;
        ShipDtlsPin: Integer;
        Ln: Integer;
        ItemNo: Code[20];
        ItemCode: Integer;
        //MC18FEB2025
        JsonObject: JsonObject;
        Seller, Buyer : JsonObject;
        ItemArray: JsonArray;
        Item: JsonObject;
        JsonText: Text;
        JsonOutput: OutStream;
        JsonInput: InStream;
        TempBlob: Codeunit "Temp Blob";
        DateTimeString: Text;
        PostingDateTime: DateTime;
        BalanceStr: Text;
    //MC18FEB2025
    Begin
        Clear(TranDtls);
        Clear(DocDtls);
        Clear(SellerDtls);
        Clear(BuyerDtls);
        Clear(DispDtls);
        Clear(ShipDtls);
        Clear(ItemListArr);
        Clear(ItemList);
        Clear(ValDtls);
        Clear(TempBlob);
        ////////// Get Sellr Detl////////
        SellerDtls_Stcd := '';
        if CompRec.get() THEN;
        if CustRec.get(SCHRec."Sell-to Customer No.") then;
        // MC18022025
        JsonObject.Add('invoiceCounter', '1');
        JsonObject.Add('transactionType', 'B2C');
        JsonObject.Add('personType', 'VATR');
        JsonObject.Add('invoiceTypeDesc', invoiceTypeDesc); //'STD'
        JsonObject.Add('currency', 'MUR');
        JsonObject.Add('invoiceIdentifier', SCHRec."No.");
        JsonObject.Add('invoiceRefIdentifier', SCHRec."Applies-to Doc. No.");
        //"reasonStated": "return of product",
        JsonObject.Add('reasonStated', 'Correction return of product');
        JsonObject.Add('previousNoteHash', 'prevNote');
        //JsonObject.Add('reasonStated', 'rgeegr');
        JsonObject.Add('totalVatAmount', SCHRec."Amount Including VAT"); //Ma
        JsonObject.Add('totalAmtWoVatCur', SCHRec."Amount");
        JsonObject.Add('totalAmtWoVatMur', SCHRec."Amount");
        JsonObject.Add('invoiceTotal', SCHRec."Amount Including VAT");
        JsonObject.Add('discountTotalAmount', SCHRec."Invoice Discount Amount");
        JsonObject.Add('totalAmtPaid', SCHRec."Amount Including VAT"); //MA08MAR2025
        PostingDateTime := CreateDateTime(SCHRec."Posting Date", 000000T); // Convert Posting Date to DateTime
        DateTimeString := Format(Date2DMY(SCHRec."Posting Date", 3));
        // for month
        if Date2DMY(SCHRec."Posting Date", 2) <= 9 then begin
            DateTimeString += '0' + Format(Date2DMY(SCHRec."Posting Date", 2));
        end else begin
            DateTimeString += Format(Date2DMY(SCHRec."Posting Date", 2));
        end;
        // for day
        if Date2DMY(SCHRec."Posting Date", 1) <= 9 then begin
            DateTimeString += '0' + Format(Date2DMY(SCHRec."Posting Date", 1));
        end else begin
            DateTimeString += Format(Date2DMY(SCHRec."Posting Date", 1));
        end;

        DateTimeString += ' 00:00:00';

        JsonObject.Add('dateTimeInvoiceIssued', DateTimeString);


        // Seller Details
        Seller.Add('name', 'Test User');
        Seller.Add('tradeName', CompRec.Name);
        Seller.Add('tan', CompRec.TAN);
        Seller.Add('brn', CompRec.BRN);
        Seller.Add('businessAddr', CompRec.Address);
        Seller.Add('businessPhoneNo', CompRec."Phone No.");
        Seller.Add('ebsCounterNo', 'a1');
        JsonObject.Add('seller', Seller);

        // Buyer Details
        Buyer.Add('name', CustRec.Name);
        Buyer.Add('tan', CustRec.TAN);
        Buyer.Add('brn', CustRec.BRN);
        Buyer.Add('businessAddr', CustRec.Address);
        Buyer.Add('buyerType', 'VATR');
        Buyer.Add('nic', '');
        JsonObject.Add('buyer', Buyer);

        // Loop through Sales Invoice Lines
        SCLRec.SetRange("Document No.", SCHRec."No.");
        SCLRec.SetFilter(Quantity, '<>%1', 0);
        SCLRec.SetFilter("No.", '<>%1', '');
        SCLRec.SetFilter("Line Amount", '<>%1', 0);
        if SCLRec.FindSet() then
            repeat
                Clear(Item);
                Item.Add('itemNo', Format(SCLRec."Line No."));
                Item.Add('taxCode', 'TC01');
                if SCLRec.Type = SCLRec.Type::Item then begin
                    Item.Add('nature', 'GOODS');

                end else begin
                    Item.Add('nature', 'GOODS');
                end;

                Item.Add('productCodeMra', 'pdtCode');
                Item.Add('productCodeOwn', 'pdtOwn');
                Item.Add('itemDesc', SCLRec.Description);
                Item.Add('quantity', Format(SCLRec.Quantity));

                BalanceStr := Format((SCLRec."Unit Price"));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('unitPrice', BalanceStr);


                Item.Add('discount', SCLRec."Line Discount %"); // Replace with actual discount if applicable
                Item.Add('discountedValue', SCLRec."Line Discount Amount"); //MA08MAR2025
                BalanceStr := Format((SCLRec.Amount));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('amtWoVatCur', BalanceStr);

                BalanceStr := Format((SCLRec.Amount));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('amtWoVatMur', BalanceStr);

                BalanceStr := Format((SCLRec."VAT %"));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('vatAmt', BalanceStr);

                // Item.Add('vatAmt', Format(SILRec."VAT %", 0, '0.00'));
                BalanceStr := Format((SCLRec."Line Amount"));
                BalanceStr := BalanceStr.Replace(',', '');
                Item.Add('totalPrice', BalanceStr);

                ItemArray.Add(Item);
            until SCLRec.Next() = 0;

        JsonObject.Add('itemList', ItemArray);
        JsonObject.Add('salesTransactions', 'CASH');

        // Convert JSON to Text using InStream
        Clear(TempBlob);
        TempBlob.CreateOutStream(JsonOutput);
        JsonObject.WriteTo(JsonOutput);

        TempBlob.CreateInStream(JsonInput);
        JsonInput.ReadText(JsonText);
        JsonText := '[' + JsonText + ']';

        exit(JsonText);

    end;



}
