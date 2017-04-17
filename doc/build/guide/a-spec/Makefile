BASE=`pwd`/../../..

DEST=$(BASE)/out/guide/a-spec
DIRS=QueueEx BinSearchHLD BinSearchLLD MinAS ImportAS ParEnv VarDecl CondExpr CondPred\
	Quantifier LetPred Function Operator RelFunc RelOp Lambda Mu SetComp LetExpr\
	ProcExpr ProcChan ProcAlph EvtHide EvtRen ZChan ZParam ZProc ZProcParam ProcChoice\
	ProcChoiceEquiv ProcState ProcCond ProcDecl SeqComp Interrupt ParComp IPC Interleave\
	IFPar ReplInternal LetProc ReplExternal ReplParallel ReplInterleave ReplIFPar\
	Basic Free TypeDef AxDef Const IntQueue Schema SchemaHoriz SchemaRef SchemaInit\
	SchemaDecor SchemaDelta SchemaMultiDecor SchemaProc SchemaProc2 SchBind SchBindOp\
	SchDecorFunc SchTypeOp SchExpr SchAppl ProcEnv GenType GenDef GenSch GenProc\
	DocInfo Desc Annotation AnnoTeX ParProp InProp LayerID OzXfm Display

.PHONY: sub clean $(DIRS)

sub:	$(DIRS)

$(DIRS):
	make -C $@

valgrind:
	for d in $(DIRS); \
	do \
	make -C $$d valgrind; \
	done

clean:
	rm -rf $(DEST)/*
