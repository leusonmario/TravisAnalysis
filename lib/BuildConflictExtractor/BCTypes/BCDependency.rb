class BCDependency

	def initialize()

	end

	def verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, filesConflicting)
		begin
			version = filesConflicting[3].to_s.match(/[0-9\.]*/)
			if ((baseLeft["pom.xml"] == rightResult["pom.xml"] and baseRight["pom.xml"] == leftResult["pom.xml"]) or (baseLeft["pom.xml"] != nil and baseRight["pom.xml"] != nil))
				urlMavenRep = "http://search.maven.org/solrsearch/select?q=g:#{filesConflicting[0]}%20AND%20a:#{filesConflicting[1]}%20AND%20v:#{version}%20AND%20p:#{filesConflicting[2]}&rows=20&wt=json"
				uriMavenRep = URI.parse(URI.encode(urlMavenRep.strip))
				req = Net::HTTP::Get.new(urlMavenRep.to_s)
				res = Net::HTTP.start(uriMavenRep.host, uriMavenRep.port) {|http|
				  http.request(req)
				}

				conflicting = false
				jsonResultReq = JSON.parse(res.body)
				aux = 1
				jsonResultReq.each do |result|
					if (aux == 2)
						if (result[1]["numFound"] > 0)
							result[1]["docs"].each do |algo|
								if (algo["a"]==artifactID and algo["v"]==version)
									conflicting = true
								end
							end
						end
					end
					aux += 1
				end
				return conflicting
			end
		rescue
			return false
		end
		return false
	end

end