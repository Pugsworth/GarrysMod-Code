if not GCompute then return; end

GCompute.IDE.KeyboardMap:Register(KEY_R, function(self, key, ctrl, shift, alt)
	
	if ctrl and shift then
		self:DispatchAction("Run Code");
	end

	return false;

end);
