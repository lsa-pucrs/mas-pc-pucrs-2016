+!jcm__focus_env_art([],_).
+!jcm__focus_env_art(L,0) <- .print("Error focusing on environment artifact ",L).

@lf_env_art[atomic]
+!jcm__focus_env_art([H|T],Try)
	: true
<-
	!jcm__focus_env_art(H,Try);
	!jcm__focus_env_art(T,Try);
	.

+!jcm__focus_env_art(art_env(W,H,""),Try)
	: true
<-
	!join_workspace(W,H);
	.

+!jcm__focus_env_art(art_env(W,H,A),Try)
	: true
<-
	!join_workspace(W,H);
	lookupArtifact(A,AId);
	+jcm__art(W,A,AId);
	focus(AId);
	.
-!jcm__focus_env_art(L,Try)
	: true
<-
//	.wait(100);
	!jcm__focus_env_art(L,Try-1);
	.

+!join_workspace(W,_) : jcm__ws(W,I) <- cartago.set_current_wsp(I).
+!join_workspace(W,"local") <- joinWorkspace(W,I); +jcm__ws(W,I).
+!join_workspace(W,local) <- joinWorkspace(W,I); +jcm__ws(W,I).
+!join_workspace(W,H) <- joinRemoteWorkspace(W,H,I); +jcm__ws(W,I).

// Query for EIS artifact
+?eis(ArtId): true <- lookupArtifact("eis", ArtId).