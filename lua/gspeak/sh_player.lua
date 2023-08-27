local meta = FindMetaTable("Player")

function meta:IsGspeakEntity()
	return true
end

function meta:IsTalking()
	return self:GetNW2Bool("Talking")
end

function meta:GetTalkmode()
	return self:GetNW2Int("Talkmode")
end

function meta:GetTsId()
	return self:GetNW2Int("TsId")
end