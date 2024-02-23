#ifndef CODENODE_TYPE_H 
#define CODENODE_TYPE_H
#include <string>
struct CodeNode {
	std::string code;
	std::string val;
};

#define newcn(name) struct CodeNode* name = new CodeNode
#endif
